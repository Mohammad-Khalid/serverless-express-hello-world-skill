# Build An Alexa Hello World Skill With Express-With-Lambda

### This is a simple tutorial to introduce a simple Alexa skill with Express-With-Lambda.

## Step 1 : 
    Clone this [Serverless hello world skill](https://github.com/Mohammad-Khalid/serverless-express-hello-world-skill.git)

### Add express-server.js file

1. Create a app.js inside lambda/
2. Add following code in it.

```

'use strict'
const express = require('express'),
      bodyParser = require('body-parser'),
      app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.post("/", async(req, res) => {

    res.send("Hello World!");
});

module.exports = app;

```

## Step 2 :
    We're using Cloud Formation to automate the process of deploying lambda and API gateway.

Go to lambda folder and run the following command :

>    `npm run setup`
> For windows
    `npm run win-setup`

Now test our serverless express is working or not by copying the ApiUrl in Cloud Formation Stack Output, test it with postman, the API should return 'Hello World!'

## Step 3 :

 Replace `app.js` code with following:

```

'use strict'
const express = require('express'),
      bodyParser = require('body-parser'),
      Alexa = require('ask-sdk-core'),
      awsServerlessExpressMiddleware = require('aws-serverless-express/middleware'),
      app = express();

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))
app.use(awsServerlessExpressMiddleware.eventContext())
      
app.post("/", async(req, res) => {

    console.log(req);

    const LaunchRequestHandler = {
    canHandle(handlerInput) {
        return handlerInput.requestEnvelope.request.type === 'LaunchRequest';
    },
    handle(handlerInput) {
        const speechText = 'Welcome to the Alexa Skills Kit, you can say hello!';

        return handlerInput.responseBuilder
        .speak(speechText)
        .reprompt(speechText)
        .withSimpleCard('Hello World', speechText)
        .getResponse();
    },
    };

    const HelloWorldIntentHandler = {
    canHandle(handlerInput) {
        return handlerInput.requestEnvelope.request.type === 'IntentRequest'
        && handlerInput.requestEnvelope.request.intent.name === 'HelloWorldIntent';
    },
    handle(handlerInput) {
        const speechText = 'Hello World!';

        return handlerInput.responseBuilder
        .speak(speechText)
        .withSimpleCard('Hello World', speechText)
        .getResponse();
    },
    };

    const HelpIntentHandler = {
    canHandle(handlerInput) {
        return handlerInput.requestEnvelope.request.type === 'IntentRequest'
        && handlerInput.requestEnvelope.request.intent.name === 'AMAZON.HelpIntent';
    },
    handle(handlerInput) {
        const speechText = 'You can say hello to me!';

        return handlerInput.responseBuilder
        .speak(speechText)
        .reprompt(speechText)
        .withSimpleCard('Hello World', speechText)
        .getResponse();
    },
    };

    const CancelAndStopIntentHandler = {
    canHandle(handlerInput) {
        return handlerInput.requestEnvelope.request.type === 'IntentRequest'
        && (handlerInput.requestEnvelope.request.intent.name === 'AMAZON.CancelIntent'
            || handlerInput.requestEnvelope.request.intent.name === 'AMAZON.StopIntent');
    },
    handle(handlerInput) {
        const speechText = 'Goodbye!';

        return handlerInput.responseBuilder
        .speak(speechText)
        .withSimpleCard('Hello World', speechText)
        .getResponse();
    },
    };

    const SessionEndedRequestHandler = {
    canHandle(handlerInput) {
        return handlerInput.requestEnvelope.request.type === 'SessionEndedRequest';
    },
    handle(handlerInput) {
        console.log(`Session ended with reason: ${handlerInput.requestEnvelope.request.reason}`);

        return handlerInput.responseBuilder.getResponse();
    },
    };

    const ErrorHandler = {
    canHandle() {
        return true;
    },
    handle(handlerInput, error) {
        console.log(`Error handled: ${error.message}`);

        return handlerInput.responseBuilder
        .speak('Sorry, I can\'t understand the command. Please say again.')
        .reprompt('Sorry, I can\'t understand the command. Please say again.')
        .getResponse();
    },
    };

    const skillBuilder = Alexa.SkillBuilders.custom()
    .addRequestHandlers(
        LaunchRequestHandler,
        HelloWorldIntentHandler,
        HelpIntentHandler,
        CancelAndStopIntentHandler,
        SessionEndedRequestHandler
    )
    .addErrorHandlers(ErrorHandler)
    .create();

    const response = await skillBuilder.invoke(req.body, req.apiGateway.context);

    res.send(response);
})
module.exports = app;

```

> To update the above changes run command in step 2.

## Step 4 :

    Update custom endpoint uri and also add `sslCertificateType` in `skill.json` file as below : 

    ```
    "apis": {
      "custom": {
        "endpoint": {
          "uri": "<Cloud-Formation-Stack-Output-ApiUrl>",
          "sslCertificateType" : "Wildcard"
        }
      }
    }
    ```

## Step 5 :

Deploy skill and model using `ASK CLI`
    `ask deploy -t skill`
    `ask deploy -t model`

To check everything has deployed successfully, open the Developer Portal and check the Hello World Skill.