const dasha = require("@dasha.ai/sdk");
const fs = require("fs");
const { Server } = require("http");

async function main() {
  const app = await dasha.deploy("./app");

  app.connectionProvider = async (conv) =>
    conv.input.phone === "chat"
      ? dasha.chat.connect(await dasha.chat.createConsoleChat())
      : dasha.sip.connect(new dasha.sip.Endpoint("default"));

  app.ttsDispatcher = () => "dasha";

  await app.start();

// server function



// example of how our server will work
function calldasha(phone, landlordName, tenantName, address) {
  const conv = app.createConversation({
    phone: phone,
    landlordName: landlordName,
    tenantName: tenantName,
    address: address
  });
}

  const conv = app.createConversation({
    phone: process.argv[2],
    landlordName: process.argv[3] ?? "Landlord",
    tenantName: process.argv[4] ?? "Tenant",
    address: process.argv[5] ?? "address"
  });
  
  if (conv.input.phone !== "chat") conv.on("transcription", console.log);

  const logFile = await fs.promises.open("./log.txt", "w");
  await logFile.appendFile("#".repeat(100) + "\n");

  conv.on("transcription", async (entry) => {
    await logFile.appendFile(`${entry.speaker}: ${entry.text}\n`);
  });

  conv.on("debugLog", async (event) => {
    if (event?.msg?.msgId === "RecognizedSpeechMessage") {
      const logEntry = event?.msg?.results[0]?.facts;
      await logFile.appendFile(JSON.stringify(logEntry, undefined, 2) + "\n");
    }
  });

  const result = await conv.execute();

  console.log(result.output);

  await app.stop();
  app.dispose();

  await logFile.close();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
