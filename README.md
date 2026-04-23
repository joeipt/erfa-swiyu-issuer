# Workshop: Generic Issuer Setup for the Swiss E-ID Ecosystem

This workshop guides you through the process of becoming a Trust Service Provider within the Swiss Trust Infrastructure. You will create a digital identity for a simulated company, configure a generic issuer, and issue a Verifiable Credential to your own swiyu wallet.

## Objectives

- Each participant is able to create their own credential and load it into their wallet.
- Participants understand the steps required to get onboarded into the base registry.

## Prerequisites

- Docker and Docker Compose
- Java 25 Temurin jdk
- jq command-line utility
- ngrok client
- swiyu wallet app installed on a mobile device
- AGOV Login

---

## Step 1: Base Onboarding Flow
Read the whole instructions of this step before clicking on the link.

Follow the official documentation at the link below to do the Base Onboarding flow

Complete the first two Steps of the Onboarding Cookbook. This includes:
- Sign up to Eportal
- Create your own Business
- Get API Key for your Application *(And save all four tokens/credentials to a local file)*

**Important: Do NOT perform Step 3 (Technical Onboarding) at this stage.**

[Onboarding into Base and Trust Registry](https://swiyu-admin-ch.github.io/cookbooks/onboarding-base-and-trust-registry/#business-partner-registration)

## Step 2: Run Onboarding Script

Navigate into the ./setup-script directory to run the [setup script](./setup-script/run-system-demo.sh). 
If you get an error that the didtoolbox is missing it is very likely you are not yet in /setup-script

The script will prompt you to enter a token (this is the access-token you got in the steps before)
And the business id you find under: https://portal.trust-infra.swiyu-int.admin.ch/ui/organizations

If the script doesnt prompt you to input your BusinessId and Token it means I forgot to update it. In that case just open the script and replace the **TOKEN** and **SWIYU_BUSINESS_ID**

The Script can fail on MacOS because of some limitation to the terminal in MacOS. In that case you can open the [script](./setup-script/run-system-demo.sh) and on line 83 replace 
```bash
read -r -p "Enter your Bearer Token: " TOKEN
echo ""
if [[ -z "$TOKEN" ]]; then
    log_error "TOKEN cannot be empty"
    exit 1
fi
```
with
```bash
TOKEN="Bearer <YOUR TOKEN HERE>"

```


## Step 3: Generic Issuer Configuration

Fill out the .env variables (Except for External_URL, which is described in 3.1)

Follow the instructions on the [Onboarding Generic Issuer](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-issuer/) page to populate your environment variables.

You must fill out the following file in this directory:
[.env](./.env)

You should find the generated [didlog](./setup-script/.didlog.jsonl) and other information in the [setup-script directory](./setup-script)

### Step 3.1: Start a local Proxy using ngrok

Start a local proxy using the following command to make your local issuer accessible to the internet:

```bash
ngrok http 8080
```
ngrok will generate a proxy adress for you which you can then enter as external url in the .env fiel

Note: You must complete the ngrok setup before running this command. This includes the installation of the software and the configuration of your authentication token.

## Step 4: Starting the Service

In the project root run 
```bash
mvn clean install -DskipTests
```

Then run the following command in a new terminal window to start your service:

```bash
docker compose -f compose.yml up --build
```

Note: If you are using an ARM processor, use the following command instead:
```bash
docker compose -f arm.compose.yml up --build
```

If everything is configured correctly in the .env file your service should now start up and you should be able to see that your ngrok proxy is connected to it.

# Step 5: Status List Creation

In the next step you create your status list. You can do this with this command:

```bash
curl -X 'POST' \
  '<{YOUR_GROK_PROXY_HERE}>/management/api/status-list' \
  -H 'Content-Type: application/json' \
  -d '{
  "type": "TOKEN_STATUS_LIST",
  "maxLength": 100000,
  "config": {
    "bits": 2
  }
}'
```

The response should look like this:
```json
{
    "id":"18f2f998-4e88-4342-8870-a5abc3cc23ce",
    "statusRegistryUrl":"https://status-reg.trust-infra.swiyu-int.admin.ch/api/v1/statuslist/30361fd9-f888-44f0-8894-2674cfde1336.jwt",
    "maxListEntries":100000,
    "remainingListEntries":100000,
    "config":{
        "purpose":"",
        "bits":2
    }
}
```
This step is also described here: [Create Status List](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-issuer/#status-list-creation)

# Step 6: Issuing your Credential

Now you can issue your first credential. Use the following command to trigger the process. Make sure you replace all the placeholders in curly braces with your own proxy URL and your personal details.

```bash
curl -X 'POST' '{YOUR_GROK_PROXY_URL}/management/api/credentials' \
  -H 'Content-Type: application/json' \
  -d '{
  "metadata_credential_supported_id": [
    "my-test-vc"
  ],
  "credential_subject_data": {
    "given_name": "{YOUR NAME}",
    "family_name": "{YOUR LAST NAME}",
    "birth_date": "{YOUR DATE OF BIRTH: DD.MM.YYYY}"
  },
  "offer_validity_seconds": 86400,
  "credential_valid_until": "2030-01-01T19:23:24Z",
  "credential_valid_from": "2025-01-01T18:23:24Z",
  "status_lists": [
    "{STATUS_REGISTRY_URL}"
  ]
}'
```

This should return a credential with a management_id, an offer_id and a deeplink offer which we can use to later create a QR Code. It should look like this:
```json
{
    "management_id":"af2328d2-ae3a-4cd2-8754-585aa8911cdb",
    "offer_id":"f2b1d9da-c874-4140-bf8b-af9538ad8fd1",
    "offer_deeplink":"swiyu://?credential_offer=%7B%22grants%22%3A%7B%22urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Apre-authorized_code%22%3A%7B%22pre-authorized_code%22%3A%22f231554c-b27e-4928-9d32-fc7a84918e64%22%7D%7D%2C%22credential_issuer%22%3A%22https%3A%2F%2Fhaunt-audible-concise.ngrok-free.dev%22%2C%22credential_configuration_ids%22%3A%5B%22my-test-vc%22%5D%7D"
}
```
You can now check the status of the credential with following command:
```bash
curl -X 'GET' "{YOUR_NGROK_ADRESS}/management/api/credentials/${management_id}/status"
```
where you should see that your Credential has been offered

This step is also described in the cookbook: [Issue Your First Credential](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-issuer/#issue-credential)

## Step 7: Adding your credential to your Wallet

Once you have received the JSON response from the issuance command, you can generate a QR code from the deeplink directly in your terminal.

```bash
echo '{YOUR_JSON_RESPONSE}' | jq -r '.offer_deeplink' | qrencode -t ANSIUTF8
```

You can scan this link with any QR Scanner (but not directly using the Swiyu App)

## Further things to try out if you have time
- [Cancel your Credential](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-issuer/#update-status)
- [Create a New Company and Onboard it into the Trust Regisrty](https://swiyu-admin-ch.github.io/cookbooks/onboarding-generic-issuer/#update-status)
- Create a Custom Credential by editing the credentials. *The Credentials are defined in the compose.yml*
- [Give your Credentials a visual Makeover](https://swiyu-admin-ch.github.io/cookbooks/vc-visual-presentation/)



