const noderfc = require("node-rfc");

const client = new noderfc.Client({ dest: "S4H" });

(async () => {
    try {
        await client.open();

        const result = await client.call("ZFM_TEST_RFC",{
			ID_PARAM1: "Teste",
			IS_SAIRPORT: {
				ID: "A01",
				NAME: "Aeroporto A01",
				TIME_ZONE: "UTC-3"
			},
			CD_PARAM1: 2,
			CS_SAIRPORT: {
				ID: "A02",
				NAME: "Aeroporto A02",
				TIME_ZONE: "UTC-2"
			},
			IT_SAIRPORT: [
				{ID: "A03",NAME: "Aeroporto A03",TIME_ZONE: "UTC-1"},
				{ID: "A04",NAME: "Aeroporto A04",TIME_ZONE: "UTC-2"},
				{ID: "A05",NAME: "Aeroporto A05",TIME_ZONE: "UTC-3"}
			]
        });

        // check the result
        console.log(result);
    } catch (err) {
        // connection and invocation errors
        console.error(err);
    }
})();
