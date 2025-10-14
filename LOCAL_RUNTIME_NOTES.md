# Local Runtime Notes

- Start the following services before running the Flutter desktop shell: Keycloak (`docker compose -f config/keycloak/docker-compose.keycloak.yml up -d`), YARP gateway (`dotnet run --project dejting-yarp/src/dejting-yarp`), UserService (`DEMO_MODE=true ASPNETCORE_URLS=http://+:8082 dotnet run`), MatchmakingService (`ConnectionStrings__DefaultConnection=Server=localhost;Port=3309;... ASPNETCORE_URLS=http://+:8083 dotnet run`), and MessagingService (`docker compose up messaging-service messaging-service-db`).
- If the app launches without a valid access token, it now redirects to the Keycloak login screen. Use the seeded demo credentials (`Demo123!`) to sign back in before attempting profile or photo actions.
- Photo uploads are disabled until a fresh Keycloak session is available. If prompted to reauthenticate, log in again and reopen the photo screen.
- Messaging UI silently skips initialization when `http://localhost:8086` is offline; warnings are logged once. Start the messaging API to enable conversations and live updates.
