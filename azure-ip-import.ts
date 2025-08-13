import * as fs from "fs";
import { $ } from "execa";

type ServiceTags = {
  values: Array<{ id: string; properties: { addressPrefixes: Array<string> } }>;
};

(async () => {
  const serviceTags: ServiceTags = JSON.parse(
    fs.readFileSync("./ServiceTags_Public_20250804.json").toString(),
  );
  const usEast2AzureCloud = serviceTags.values.find(
    (value) => value.id === "AzureCloud.eastus2",
  );
  if (usEast2AzureCloud === undefined)
    throw new Error("unable to find us east 2");
  const ipv4addresses = usEast2AzureCloud.properties.addressPrefixes.filter(
    (address) => {
      return /([0-255].{3})[0-255]\/[0-255]/.test(address);
    },
  );

  const containerAppName = "";
  const resourceGroupName = "";
  const restrictionName = "api-gateway";
  ipv4addresses.forEach(async(address, index) => {
    await $`az containerapp ingress access-restriction set -n ${containerAppName} -g ${resourceGroupName}
      --rule-name ${restrictionName}-${index} --ip-address ${address} --action Allow`;
  })
})();
