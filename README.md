# Workshop: Generic Issuer Setup for the Swiss E-ID Ecosystem

This workshop guides you through the process of becoming a Trust Service Provider within the Swiss Trust Infrastructure. You will create a digital identity for a simulated company, configure a generic issuer, and issue a Verifiable Credential to your own swiyu wallet.

## Objectives
- Distinguish between the Base Registry and the Trust Registry.
- Establish a Decentralized Identifier (DID) for a simulated organization.
- Issue a digital credential and manage it within the swiyu mobile application.

## Prerequisites
- A mobile device with the swiyu wallet app installed (available on iOS and Android).
- A laptop with internet access.
- The swiyu wallet must be set up and ready for use.

---

## Step 1: Onboarding to the Base Registry

Every issuer in the Swiss ecosystem must first have a valid digital identity. We use the Base Registry to register our "Fake Company."

1. Open the official cookbook: [Onboarding Base and Trust Registry](https://swiyu-admin-ch.github.io/cookbooks/onboarding-base-and-trust-registry/)
2. Follow the instructions specifically for the **Base Registry Onboarding**.
3. **Important:** Stop once you have completed the Base Registry steps. **Do not proceed to the Trust Registry onboarding.**

**Note on Trust Levels:**
By completing the Base Registry onboarding, your company technically exists and can sign credentials. However, because you are skipping the Trust Registry, your company is not "verified" by the federal authorities. This will cause a warning in the wallet app later, which is expected for this exercise.

---

## Step 2: Configure the Generic Issuer

After obtaining your DID and technical keys from the previous step, you must connect them to the issuer interface.

1. Navigate to the Generic Issuer URL: [Insert Workshop Issuer URL Here]
2. Provide your Organization DID generated during the onboarding.
3. Select the credential schema provided for this workshop (e.g., Workshop Participation Certificate).
4. Enter the required metadata for your issuer instance.

---

## Step 3: Issue a Verifiable Credential

Now you will act as the issuer to provide a credential to yourself.

1. In the Generic Issuer interface, navigate to the "Issue Credential" section.
2. Input your name and any other required attributes into the form.
3. Click on "Generate Offer" or "Issue."
4. A QR code will be displayed on your screen. This represents the credential offer.

---

## Step 4: Receive the Credential in swiyu Wallet

1. Open the swiyu wallet app on your mobile device.
2. Select the scan function.
3. Scan the QR code shown on your laptop screen.
4. The app will display a warning stating that the issuer is "Unknown" or "Not Trusted." This is because we did not register in the Trust Registry.
5. Select "Proceed" or "Accept anyway" to add the credential to your wallet.
6. Verify that the credential appears in your wallet list with the attributes you entered.

---

## Technical Context

### Base Registry vs. Trust Registry
- **Base Registry:** A technical directory (using DID:Web or similar methods) that allows parties to find public keys and service endpoints. It proves that an identity exists.
- **Trust Registry:** A governance layer where the federal government (or a