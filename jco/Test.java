package main;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.io.Writer;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Date;
import java.util.Iterator;
import java.util.Properties;

import com.sap.conn.jco.JCoAbapObject;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoDestinationManager;
import com.sap.conn.jco.JCoField;
import com.sap.conn.jco.JCoFieldIterator;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoMetaData;
import com.sap.conn.jco.JCoParameterField;
import com.sap.conn.jco.JCoParameterFieldIterator;
import com.sap.conn.jco.JCoParameterList;
import com.sap.conn.jco.JCoRecord;
import com.sap.conn.jco.JCoRecordFieldIterator;
import com.sap.conn.jco.JCoRecordMetaData;
import com.sap.conn.jco.JCoRepository;
import com.sap.conn.jco.JCoStructure;
import com.sap.conn.jco.JCoTable;
import com.sap.conn.jco.ext.DestinationDataProvider;

public class Test {

	public static void main(String[] args) {
		try {
			String DESTINATION_SAP1 = "SAPSYSTEM1";
			
			createDestinationDataFile(DESTINATION_SAP1);
			
			final String functionModule = "ZFM_TEST_RFC";
	        JCoDestination destination = JCoDestinationManager.getDestination(DESTINATION_SAP1);
	        JCoFunction function = destination.getRepository().getFunction(functionModule);
	        if (function == null) {
	            throw new RuntimeException(functionModule+" não encontrada");
	        }
	        
	        JCoRepository repository = destination.getRepository();
			
			// remove cache de estrutura
			repository.clear();
	        
			// importação: parâmetros simples
	        function.getImportParameterList().setValue("ID_PARAM1", "Teste");
	        
	        // importação: estruturas
	        JCoStructure importStructure = function.getImportParameterList().getStructure("IS_SAIRPORT");
	        importStructure.setValue("ID","ABC");
	        importStructure.setValue("NAME","Aeroporto ABC");
	        importStructure.setValue("TIME_ZONE","UTC+9");
	        
	        // modificação: parâmetros simples
	        function.getChangingParameterList().setValue("CD_PARAM1", 1);
	        
	        // modificação: estruturas
	        JCoStructure changingStructure = function.getChangingParameterList().getStructure("CS_SAIRPORT");
	        changingStructure.setValue("ID","ABC");
	        changingStructure.setValue("NAME","Aeroporto ABC");
	        changingStructure.setValue("TIME_ZONE","UTC+1");
	        
	        // tabelas de entrada
	        JCoTable importTable = function.getTableParameterList().getTable("IT_SAIRPORT");
	        importTable.insertRow(1);
	        importTable.setValue(1, "A01");
	        importTable.setValue(2, "Aeroporto A01");
	        importTable.setValue(3, "UTF-1");
	        
	        importTable.insertRow(2);
	        importTable.setValue(1, "A02");
	        importTable.setValue(2, "Aeroporto A02");
	        importTable.setValue(3, "UTF-2");
	        
	        // executando chamada remota
	        function.execute(destination);
	        
	        // exportação: parâmetros simples
	        System.out.print("exportacao - simples:    ");
	        System.out.print(function.getExportParameterList().getValue("ED_PARAM1"));
	        System.out.println("");
	        
	        // exportação: estruturas
	        System.out.print("exportacao - estruturas: ");
	        JCoStructure structure1 = function.getExportParameterList().getStructure("ES_SAIRPORT");
	        System.out.print(structure1.getValue("ID")+", ");
	        System.out.print(structure1.getValue("NAME")+", ");
	        System.out.print(structure1.getValue("TIME_ZONE"));
	        System.out.println("");
	        
	        // modificação: parâmetros simples
	        System.out.print("changing - simples:      ");
	        System.out.print(function.getChangingParameterList().getValue("CD_PARAM1"));
	        System.out.println("");
	        
	        // modificação: estruturas
	        System.out.print("changing - estruturas:   ");
	        JCoStructure structure2 = function.getChangingParameterList().getStructure("CS_SAIRPORT");
	        System.out.print(structure2.getValue("ID")+", ");
	        System.out.print(structure2.getValue("NAME")+", ");
	        System.out.print(structure2.getValue("TIME_ZONE"));
	        System.out.println("\n");
	        
	        // tabelas de saída
	        System.out.println("tabelas de saida");
	        
	        JCoTable exportTable = function.getTableParameterList().getTable("ET_SAIRPORT");
	        
	        System.out.println("ET_SAIRPORT ("+exportTable.getNumRows()+" linhas)");
	        
	        // cabeçalho
	        System.out.println("-------------------------------------");
        	for(int j=0;j < exportTable.getFieldCount();j++){
        		String label = exportTable.getMetaData().getName(j);
        		System.out.print("|");
        		System.out.print(label+"\t");
        	}
        	System.out.println("|");
        	System.out.println("-------------------------------------");
	        
	        for(int i=0;i < exportTable.getNumRows();i++){
	        	exportTable.setRow(i);
	        	
	        	for(int j=0;j < exportTable.getFieldCount();j++){
	        		Object value = exportTable.getValue(j);
	        		System.out.print("|");
        			System.out.print(value+"\t");
	        	}
	        	System.out.println("|");
	        }
	        
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	static void createDestinationDataFile(String destinationName)
    {    
        //SAP System 1
        Properties connectProperties = new Properties();
        connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST, "192.168.0.10");
        connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR,  "00");
        connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT, "800");
        connectProperties.setProperty(DestinationDataProvider.JCO_USER,   "DEVELOPER");
        connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD, "abap001");
        connectProperties.setProperty(DestinationDataProvider.JCO_LANG,   "en");
        
        File destCfg = new File(destinationName+".jcoDestination");
        try
        {
            FileOutputStream fos = new FileOutputStream(destCfg, false);
            connectProperties.store(fos, "for tests only !");
            fos.close();
        }
        catch (Exception e)
        {
            throw new RuntimeException("Unable to create the destination files", e);
        }
    }
}
