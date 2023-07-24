// diretório nwrfcsdk deve existir na pasta do node
// sapnwrfc.ini deve existir na pasta do node
const nodeRfc = require('node-rfc');
const pool = new nodeRfc.Pool({ connectionParameters: { dest: "S4H" }});

(async () => {
    try {
        const client = await pool.acquire();

        //const result = await client.call("BAPI_USER_GET_DETAIL", {
        //    USERNAME: "DEVELOPER",
        //});

		const result = await client.call("ZFM_TEST_RFC", {
            ID_PARAM1: "1",
			IS_SAIRPORT: {
				'ID': 'ABC'
			},
			CS_SAIRPORT: {
				'ID': 'ABC'
			},
			CD_PARAM1: 1,
			IT_SAIRPORT: [
			{
				'ID': 'AAA'
			},
			{
				'ID': 'AAA'
			}
			
			]
        });

			
        console.log(result);
    
    } catch (err) {
        console.error(err);
    }
})();
