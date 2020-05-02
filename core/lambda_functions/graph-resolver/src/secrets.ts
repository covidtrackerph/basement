import {
  SecretsManagerClient,
  GetSecretValueCommand
} from "@aws-sdk/client-secrets-manager-node";

const secretsManager = new SecretsManagerClient({
  region: "ap-southeast-1"
});

const secrets = new Map<string, any>();

/**
 * Get a JSON-encoded secret value.
 * @param secretName Name of the secret.
 */
export const getSecretValue = async <T>(secretName: string): Promise<T> => {
  let value: T;
  if (secrets.has(secretName)) {
    console.debug(`Secret '${secretName}' cached, returning.`);
    value = secrets.get(secretName) as T;
  } else {
    console.debug(`Secret '${secretName}' not cached, retrieving.`);
    try {
      const secret = await secretsManager.send(
        new GetSecretValueCommand({
          SecretId: secretName
        })
      );

      if (secret.SecretString) {
        console.debug(`Secret '${secretName}' retrieved.`);
        value = JSON.parse(secret.SecretString, toCamelCase);
        secrets.set(secretName, value);
      } else {
        const message = `Missing 'SecretString' property for secret '${secretName}'.`;
        console.error(message);
        throw new Error(message);
      }
    } catch (error) {
      console.error(`Failed to retrieve secret '${secretName}'.`, error);
      throw error;
    }
  }

  return value;
};

function toCamelCase(key: string, value: any) {
    if (value && typeof value === 'object'){
      for (var k in value) {
        if (/^[A-Z]/.test(k) && Object.hasOwnProperty.call(value, k)) {
          value[k.charAt(0).toLowerCase() + k.substring(1)] = value[k];
          delete value[k];
        }
      }
    }
    return value;
  }