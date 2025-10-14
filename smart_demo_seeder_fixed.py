#!/usr/bin/env python3
"""
Smart Demo Data Seeder (Keycloak edition)
Seeds realistic demo data by provisioning Keycloak users and populating
platform APIs through the YARP gateway.
"""

import json
import os
import random
import time
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Dict, Optional

import requests


# Swedish-inspired demo users with ASCII usernames for compatibility
DEMO_USERS = [
    {
        "fullName": "Erik Astrom",
        "username": "erik_astrom",
        "email": "erik.astrom@demo.com",
        "bio": "Älskar att vandra i svenska fjällen och upptäcka nya platser. Jobbar som mjukvaruingenjör och spelar gitarr på fritiden.",
        "age": 28,
        "location": "Stockholm",
        "interests": "Vandring, musik, teknik",
    },
    {
        "fullName": "Anna Lindberg",
        "username": "anna_lindberg",
        "email": "anna.lindberg@demo.com",
        "bio": "Fotograf med passion för naturbilder och porträtt. Älskar att resa och upptäcka nya kulturer.",
        "age": 25,
        "location": "Göteborg",
        "interests": "Fotografi, resor, konst",
    },
    {
        "fullName": "Oskar Kallstrom",
        "username": "oskar_kallstrom",
        "email": "oskar.kallstrom@demo.com",
        "bio": "Kock som älskar att experimentera med nordiska ingredienser. Springer maraton och läser deckare.",
        "age": 32,
        "location": "Malmö",
        "interests": "Matlagning, löpning, böcker",
    },
    {
        "fullName": "Sara Blomqvist",
        "username": "sara_blomqvist",
        "email": "sara.blomqvist@demo.com",
        "bio": "Veterinär som bryr sig om djur och natur. Tycker om att måla akvarell och laga vegetarisk mat.",
        "age": 29,
        "location": "Uppsala",
        "interests": "Djur, målning, vegetarisk mat",
    },
    {
        "fullName": "Magnus Ohman",
        "username": "magnus_ohman",
        "email": "magnus.ohman@demo.com",
        "bio": "Lärare i historia som fascineras av vikingatiden. Spelar ishockey och bygger modellflygplan.",
        "age": 35,
        "location": "Linköping",
        "interests": "Historia, ishockey, modellflygplan",
    },
]


def _split_name(full_name: str) -> Dict[str, str]:
    parts = full_name.strip().split(" ", 1)
    first = parts[0]
    last = parts[1] if len(parts) > 1 else "Demo"
    return {"first": first, "last": last}


@dataclass
class KeycloakConfig:
    base_url: str = os.environ.get("KEYCLOAK_URL", "http://localhost:8090").rstrip("/")
    realm: str = os.environ.get("KEYCLOAK_REALM", "DatingApp")
    admin_user: str = os.environ.get("KEYCLOAK_ADMIN", "admin")
    admin_password: str = os.environ.get("KEYCLOAK_ADMIN_PASSWORD", "admin")
    client_id: str = os.environ.get("KEYCLOAK_CLIENT_ID", "dejtingapp-flutter")
    client_scopes: str = os.environ.get("KEYCLOAK_CLIENT_SCOPES", "openid profile email offline_access")
    user_password: str = os.environ.get("DEMO_USER_PASSWORD", "Demo123!")
    gateway_url: str = os.environ.get("DATINGAPP_GATEWAY_URL", "http://localhost:8080/api").rstrip("/")
    gateway_health: str = os.environ.get("DATINGAPP_GATEWAY_HEALTH", "http://localhost:8080/health")
    user_health: str = os.environ.get("USER_SERVICE_HEALTH", "http://localhost:8082/health")
    matchmaking_health: str = os.environ.get("MATCHMAKING_SERVICE_HEALTH", "http://localhost:8083/health")


class KeycloakAdminClient:
    """Minimal helper for interacting with the Keycloak Admin REST API."""

    def __init__(self, config: KeycloakConfig, session: Optional[requests.Session] = None):
        self._config = config
        self._session = session or requests.Session()
        self._admin_token: Optional[str] = None
        self._token_expires_at: Optional[datetime] = None

    def _get_admin_token(self) -> str:
        now = datetime.utcnow()
        if self._admin_token and self._token_expires_at and now < self._token_expires_at - timedelta(seconds=30):
            return self._admin_token

        data = {
            "grant_type": "password",
            "client_id": "admin-cli",
            "username": self._config.admin_user,
            "password": self._config.admin_password,
        }
        token_url = f"{self._config.base_url}/realms/master/protocol/openid-connect/token"
        response = self._session.post(token_url, data=data, timeout=15)
        response.raise_for_status()

        payload = response.json()
        self._admin_token = payload["access_token"]
        ttl = int(payload.get("expires_in", 60))
        self._token_expires_at = now + timedelta(seconds=ttl)
        return self._admin_token

    def _auth_headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self._get_admin_token()}",
            "Content-Type": "application/json",
        }

    def ensure_user(self, username: str, email: str, first_name: str, last_name: str) -> str:
        payload = {
            "username": username,
            "email": email,
            "firstName": first_name,
            "lastName": last_name,
            "enabled": True,
            "emailVerified": True,
            "realmRoles": ["user"],
        }

        users_url = f"{self._config.base_url}/admin/realms/{self._config.realm}/users"
        response = self._session.post(users_url, headers=self._auth_headers(), json=payload, timeout=15)

        if response.status_code == 201:
            location = response.headers.get("Location", "")
            return location.rstrip("/").split("/")[-1]

        if response.status_code == 409:
            existing = self.find_user(username)
            if existing:
                return existing["id"]
            raise RuntimeError(f"User {username} already exists but could not be fetched")

        response.raise_for_status()
        raise RuntimeError(f"Unexpected response creating user {username}: {response.status_code}")

    def find_user(self, username: str) -> Optional[Dict[str, Any]]:
        params = {"username": username}
        url = f"{self._config.base_url}/admin/realms/{self._config.realm}/users"
        response = self._session.get(url, headers=self._auth_headers(), params=params, timeout=15)
        response.raise_for_status()
        results = response.json()
        return results[0] if results else None

    def set_password(self, user_id: str, password: str) -> None:
        reset_url = f"{self._config.base_url}/admin/realms/{self._config.realm}/users/{user_id}/reset-password"
        payload = {"type": "password", "value": password, "temporary": False}
        response = self._session.put(reset_url, headers=self._auth_headers(), json=payload, timeout=15)
        response.raise_for_status()

    def obtain_user_token(self, username: str, password: str) -> Optional[str]:
        token_url = f"{self._config.base_url}/realms/{self._config.realm}/protocol/openid-connect/token"
        data = {
            "grant_type": "password",
            "client_id": self._config.client_id,
            "username": username,
            "password": password,
            "scope": self._config.client_scopes,
        }

        response = self._session.post(token_url, data=data, timeout=15)
        if response.status_code == 200:
            return response.json().get("access_token")

        if response.status_code == 400:
            print(f"⚠️ Unable to get token for {username}: {response.text}")
            return None

        response.raise_for_status()
        return None


class SmartDemoSeeder:
    def __init__(self):
        self.config = KeycloakConfig()
        self.session = requests.Session()
        self.keycloak = KeycloakAdminClient(self.config, session=self.session)

        self.userprofiles_url = f"{self.config.gateway_url}/userprofiles"
        self.matchmaking_url = f"{self.config.gateway_url}/matchmaking"

        self.auth_tokens: Dict[str, str] = {}
        self.user_profiles: Dict[str, Dict[str, Any]] = {}

    def print_step(self, message: str, level: str = "INFO") -> None:
        colors = {
            "INFO": "\033[94m",
            "SUCCESS": "\033[92m",
            "WARNING": "\033[93m",
            "ERROR": "\033[91m",
            "HEADER": "\033[95m",
            "ENDC": "\033[0m",
        }
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"{colors.get(level, '')}{timestamp} | {message}{colors['ENDC']}")

    def check_services_health(self) -> bool:
        self.print_step("🏥 Checking service health...", "HEADER")

        services = [
            ("Keycloak", f"{self.config.base_url}/realms/{self.config.realm}"),
            ("YARP Gateway", self.config.gateway_health),
            ("UserService", self.config.user_health),
            ("MatchmakingService", self.config.matchmaking_health),
        ]

        all_healthy = True
        for name, url in services:
            try:
                response = self.session.get(url, timeout=5)
                if response.status_code in (200, 204):
                    self.print_step(f"✅ {name}: Healthy", "SUCCESS")
                else:
                    self.print_step(
                        f"⚠️ {name}: HTTP {response.status_code} ({response.text[:100]})",
                        "WARNING",
                    )
                    all_healthy = False
            except requests.exceptions.RequestException as error:
                self.print_step(f"❌ {name}: Connection failed - {error}", "ERROR")
                all_healthy = False

        return all_healthy

    def register_users(self) -> None:
        self.print_step("👥 Registering demo users in Keycloak...", "HEADER")

        for index, user in enumerate(DEMO_USERS, start=1):
            self.print_step(f"Provisioning user {index}/{len(DEMO_USERS)}: {user['fullName']}")
            names = _split_name(user["fullName"])

            try:
                user_id = self.keycloak.ensure_user(
                    username=user["username"],
                    email=user["email"],
                    first_name=names["first"],
                    last_name=names["last"],
                )
                self.keycloak.set_password(user_id, self.config.user_password)

                token = self.keycloak.obtain_user_token(user["username"], self.config.user_password)
                if token:
                    self.auth_tokens[user["username"]] = token
                    self.print_step(f"✅ Keycloak ready: {user['fullName']}", "SUCCESS")
                else:
                    self.print_step(f"⚠️ Could not obtain token for {user['fullName']}", "WARNING")

            except requests.exceptions.RequestException as error:
                self.print_step(f"❌ Network error provisioning {user['fullName']}: {error}", "ERROR")
            except Exception as error:  # pylint: disable=broad-except
                self.print_step(f"❌ Failed to provision {user['fullName']}: {error}", "ERROR")

            time.sleep(0.5)

    def create_user_profiles(self) -> None:
        self.print_step("📝 Creating user profiles via gateway...", "HEADER")

        for index, user in enumerate(DEMO_USERS, start=1):
            username = user["username"]
            token = self.auth_tokens.get(username)
            if not token:
                self.print_step(
                    f"⚠️ Skipping profile for {user['fullName']} - token missing",
                    "WARNING",
                )
                continue

            self.print_step(f"Creating profile {index}/{len(DEMO_USERS)}: {user['fullName']}")

            birth_year = datetime.now().year - user["age"]
            birth_date = f"{birth_year}-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"

            profile_data = {
                "name": user["fullName"],
                "email": user["email"],
                "bio": user["bio"],
                "gender": random.choice(["Male", "Female"]),
                "preferences": random.choice(["Male", "Female", "Both"]),
                "dateOfBirth": f"{birth_date}T00:00:00Z",
                "city": user["location"],
                "country": "Sweden",
                "interests": [],
                "languages": [],
                "occupation": random.choice([
                    "Software Engineer",
                    "Photographer",
                    "Chef",
                    "Veterinarian",
                    "Teacher",
                    "Designer",
                    "Entrepreneur",
                    "Journalist",
                    "Architect",
                    "Researcher",
                    "Psychologist",
                    "Electrician",
                ]),
                "education": random.choice([
                    "University Degree",
                    "Master's Degree",
                    "High School",
                    "PhD",
                    "Trade School",
                    "Bachelor's Degree",
                ]),
                "height": random.randint(160, 195),
                "relationshipType": "Long-term relationship",
                "smokingStatus": random.choice(["Non-smoker", "Occasionally", "Never"]),
                "drinkingStatus": random.choice(["Socially", "Occasionally", "Never"]),
                "wantsChildren": random.choice([True, False]),
                "hasChildren": random.choice([True, False]),
            }

            headers = {"Authorization": f"Bearer {token}"}

            try:
                response = self.session.post(self.userprofiles_url, json=profile_data, headers=headers, timeout=15)
                if response.status_code in (200, 201):
                    profile = response.json() if response.content else {}
                    self.user_profiles[username] = profile
                    self.print_step(f"✅ Profile created: {user['fullName']}", "SUCCESS")
                elif response.status_code == 409:
                    self.print_step(
                        f"⚠️ Profile already exists for {user['fullName']}",
                        "WARNING",
                    )
                else:
                    self.print_step(
                        f"❌ Failed to create profile for {user['fullName']}: HTTP {response.status_code}",
                        "ERROR",
                    )
                    if response.text:
                        self.print_step(f"Error details: {response.text}", "ERROR")
            except requests.exceptions.RequestException as error:
                self.print_step(f"❌ Network error creating profile for {user['fullName']}: {error}", "ERROR")

            time.sleep(0.5)

    def setup_demo_matches(self) -> None:
        self.print_step("💕 Setting up demo matches...", "HEADER")

        registered_users = [user for user in DEMO_USERS if user["username"] in self.auth_tokens]
        if len(registered_users) < 2:
            self.print_step("⚠️ Need at least 2 registered users for matches", "WARNING")
            return

        user_ids: Dict[str, int] = {}
        for user in registered_users:
            profile = self.user_profiles.get(user["username"])
            if profile and profile.get("id"):
                user_ids[user["username"]] = profile["id"]
                continue

            token = self.auth_tokens[user["username"]]
            headers = {"Authorization": f"Bearer {token}"}
            search_payload = {"page": 1, "pageSize": 20}

            try:
                response = self.session.post(
                    f"{self.userprofiles_url}/search",
                    json=search_payload,
                    headers=headers,
                    timeout=15,
                )
                if response.status_code == 200:
                    results = response.json().get("results", [])
                    for profile_result in results:
                        if profile_result.get("name") == user["fullName"]:
                            user_ids[user["username"]] = profile_result.get("id")
                            break
            except Exception as error:  # pylint:disable=broad-except
                self.print_step(f"❌ Error getting user ID for {user['fullName']}: {error}", "ERROR")

        self.print_step(f"📋 Found {len(user_ids)} user IDs: {list(user_ids.values())}", "INFO")

        pairs = list(user_ids.items())
        for idx in range(min(3, len(pairs) - 1)):
            user1_name, user1_id = pairs[idx]
            user2_name, user2_id = pairs[idx + 1]
            if not user1_id or not user2_id:
                continue

            self.print_step(f"Creating mutual match: {user1_name} ↔ {user2_name}")

            payload = {
                "user1Id": user1_id,
                "user2Id": user2_id,
                "compatibilityScore": round(random.uniform(75.0, 95.0), 2),
                "source": "demo_seeder",
            }
            headers = {"Authorization": f"Bearer {self.auth_tokens[user1_name]}"}

            try:
                response = self.session.post(
                    f"{self.matchmaking_url}/matches",
                    json=payload,
                    headers=headers,
                    timeout=15,
                )
                if response.status_code in (200, 201):
                    self.print_step(f"✅ Created match: {user1_name} ↔ {user2_name}", "SUCCESS")
                else:
                    self.print_step(
                        f"⚠️ Match creation returned HTTP {response.status_code}",
                        "WARNING",
                    )
                    if response.text:
                        self.print_step(f"Response: {response.text}", "INFO")
            except Exception as error:  # pylint:disable=broad-except
                self.print_step(f"❌ Error creating match: {error}", "ERROR")

            time.sleep(0.5)

        if user_ids:
            username, user_id = list(user_ids.items())[0]
            self.print_step(f"🔍 Testing match suggestions for {username}...")

            headers = {"Authorization": f"Bearer {self.auth_tokens[username]}"}
            suggestions_payload = {"userId": user_id, "limit": 5, "minScore": 50.0}

            try:
                response = self.session.post(
                    f"{self.matchmaking_url}/find-matches",
                    json=suggestions_payload,
                    headers=headers,
                    timeout=15,
                )
                if response.status_code == 200:
                    matches = response.json()
                    self.print_step(f"✅ Found {len(matches)} potential matches for {username}", "SUCCESS")
                else:
                    self.print_step(
                        f"⚠️ Find matches returned HTTP {response.status_code}",
                        "WARNING",
                    )
            except Exception as error:  # pylint:disable=broad-except
                self.print_step(f"❌ Error testing find matches: {error}", "ERROR")

    def run_seeding(self) -> bool:
        self.print_step("🚀 Starting Smart Demo Data Seeding...", "HEADER")

        if not self.check_services_health():
            self.print_step("❌ Some services are not healthy. Please start all services first.", "ERROR")
            return False

        self.register_users()
        self.create_user_profiles()
        self.setup_demo_matches()

        self.print_step("🎉 Demo seeding completed!", "SUCCESS")
        self.print_step(f"📊 Provisioned {len(self.auth_tokens)} users successfully", "INFO")
        return True


if __name__ == "__main__":
    seeder = SmartDemoSeeder()
    seeder.run_seeding()
