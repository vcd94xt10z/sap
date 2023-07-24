const nodeRfc = require('node-rfc');
const pool = new nodeRfc.Pool({ connectionParameters: { dest: "S4H" }});

(async () => {
    try {
        const client = await pool.acquire();

        const result = await client.call("BAPI_USER_GET_DETAIL", {
            USERNAME: "DEVELOPER",
        });

        console.log(result);
    
    } catch (err) {
        console.error(err);
    }
})();
