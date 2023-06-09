@isTest
public with sharing class VueloRestTest {
    @TestSetup
    static void makeData(){
        Date fecha = System.today();
        List<Aeropuerto__c> aeropuertos = new List<Aeropuerto__c>();
        List<String> ciudades =new List<String>{'Medellín', 'Bogotá'};
        List<String> aeroNombres =new List<String>{'Aeropuerto Internacional José María Cordova', 'Aeropuerto Internacional El Dorado'};
        List<String> codigos =new List<String>{'MDE', 'BOG'};
        for (Integer i=0; i<2; i++) {
            Aeropuerto__c aero = new Aeropuerto__c(Name = aeroNombres[i],
            Codigo_IATA__c = codigos[i],
            Ciudad__c = ciudades[i]);
            aeropuertos.add(aero);
        }
        Insert aeropuertos;

        List<Aeropuerto__c> a = [SELECT Id FROM Aeropuerto__c];

        List<String> idAeros = new List<String>();
        idAeros.add(a[0].Id);
        idAeros.add(a[1].Id);

        List<Contact> lista = new List<Contact>();
        for(Integer i = 0; i < 2; i++){
            Contact cto = new Contact(FirstName = 'Abigail', LastName = 'Gray', 
                                  Tipo_de_Identificaci_n__c = 'Cedula de Extranjería', Numero_de_Identificacion__c = '12'+i);
            lista.add(cto);
        }
        insert lista;
        String id = lista[0].Id;

        Avion__c avion = new Avion__c(Tipo__c  = 'Airbus A330', Numero_de_pasajeros_negocios__c = 30, Numero_de_pasajeros_Clase_Turista__c = 222);
        insert avion;
        String idAvion = avion.Id;

        Product2 vuelo = new Product2(Name = 'AE-2005', Avion__c = idAvion,
                                    Aeropuerto_de_Partida__c = idAeros[0],
                                    Aeropuerto_de_Llegada__c = idAeros[1],
                                    Fecha_y_hora_de_partida__c = Datetime.now(),
                                    Fecha_y_hora_estimada_de_llegada__c = Datetime.now().addDays(2));
        insert Vuelo;
        String idV = Vuelo.Id;
        Id idEstandar = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = idEstandar, Product2Id = idV ,
        UnitPrice = 100000, IsActive = true);
        insert standardPrice;

        Pricebook2 negocios = new Pricebook2(Name = 'Tiquetes Clase Negocios', IsActive = true);
        insert negocios;


        Pricebook2 turista = new Pricebook2(Name = 'Tiquetes clase turista', IsActive = true);
        insert turista;

        PricebookEntry entrada = new PricebookEntry(Pricebook2Id = negocios.id, Product2Id = idV, UnitPrice = 200000, isActive = true);
        insert entrada;

        Contact cto = new Contact(FirstName = 'Abigail', LastName = 'Gray', 
                                  Tipo_de_Identificaci_n__c = 'Cedula de Extranjería', Numero_de_Identificacion__c = '123');
        Insert cto;



        Opportunity reserva = new Opportunity(StageName = 'Pre-venta', Pricebook2Id =  negocios.id , Titular_de_la_reserva__c = cto.Id, Name = 'A', CloseDate = fecha);
        Insert reserva;

        String resId = reserva.Id;

        OpportunityLineItem tiquete = new OpportunityLineItem(OpportunityId = resId, Quantity = 1, Product2Id = idV);
        Insert tiquete;

    }

    @isTest 
    static void getVuelos() {
        String fecha1 = String.valueOf(Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format()).replace('/', '-') ;
        String fecha2 = String.valueOf(Date.newInstance(Date.today().addDays(30).year(), Date.today().addDays(30).month(), Date.today().addDays(30).day()).format()).replace('/', '-');

        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/Product2/';
        request.addParameter('fecha1', fecha1);
        request.addParameter('fecha2', fecha2);
        request.addParameter('ciudadPartida', 'Medellín');
        request.addParameter('ciudadDestino', 'Bogotá');
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        VueloRest.vueloWrapper result = VueloRest.getVuelos();
        // Verify results
        
        List<Product2> vuelitos = result.vuelitos; 
        String respuesta = result.mensaje;
        Boolean resultado = result.resultado;
        
        System.assert(vuelitos != null);
        System.assertEquals('Respuesta exitosa', respuesta);
        System.assertEquals(true, resultado);
    }
    

    @isTest 
    static void getVuelosErrorFechaPartidaErr() {
        String fecha1 = String.valueOf(Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format());
        String fecha2 = String.valueOf(Date.newInstance(Date.today().addDays(30).year(), Date.today().addDays(30).month(), Date.today().addDays(30).day()).format()).replace('/', '-');

        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/Product2/';
        request.addParameter('fecha1', '2022-09-10');
        request.addParameter('fecha2', fecha2);
        request.addParameter('ciudadPartida', 'Medellín');
        request.addParameter('ciudadDestino', 'Bogotá');
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        VueloRest.vueloWrapper result = VueloRest.getVuelos();
        // Verify results
        
        List<Product2> vuelitos = result.vuelitos; 
        String respuesta = result.mensaje;
        Boolean resultado = result.resultado;
        
        System.assert(vuelitos != null);
        System.assertEquals('Formato de fecha de partida incorrecto, ingrese DD-MM-YYYY', respuesta);
        System.assertEquals(false, resultado);
    }

    @isTest 
    static void getVuelosErrorFechaLlegadaErr() {
        String fecha1 = String.valueOf(Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format());
        String fecha2 = String.valueOf(Date.newInstance(Date.today().addDays(30).year(), Date.today().addDays(30).month(), Date.today().addDays(30).day()).format()).replace('/', '-');

        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/Product2/';
        request.addParameter('fecha1', fecha1);
        request.addParameter('fecha2', '2022-09-10');
        request.addParameter('ciudadPartida', 'Medellín');
        request.addParameter('ciudadDestino', 'Bogotá');
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        VueloRest.vueloWrapper result = VueloRest.getVuelos();
        // Verify results
        
        List<Product2> vuelitos = result.vuelitos; 
        String respuesta = result.mensaje;
        Boolean resultado = result.resultado;
        
        System.assert(vuelitos != null);
        System.assertEquals('Formato de fecha de llegada incorrecto, ingrese DD-MM-YYYY', respuesta);
        System.assertEquals(false, resultado);
    }

    @isTest 
    static void getVuelosErrorCiudadPartidaErr() {
        String fecha1 = String.valueOf(Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format());
        String fecha2 = String.valueOf(Date.newInstance(Date.today().addDays(30).year(), Date.today().addDays(30).month(), Date.today().addDays(30).day()).format()).replace('/', '-');

        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/Product2/';
        request.addParameter('fecha1', fecha1);
        request.addParameter('fecha2', fecha2);
        request.addParameter('ciudadPartida', 'Medellin');
        request.addParameter('ciudadDestino', 'Bogotá');
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        VueloRest.vueloWrapper result = VueloRest.getVuelos();
        // Verify results
        
        List<Product2> vuelitos = result.vuelitos; 
        String respuesta = result.mensaje;
        Boolean resultado = result.resultado;
        
        System.assert(vuelitos != null);
        System.assertEquals('La cuidad de partida no tiene cobertura', respuesta);
        System.assertEquals(false, resultado);
    }

    @isTest 
    static void getVuelosErrorCiudadLlegadaErr() {
        String fecha1 = String.valueOf(Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format());
        String fecha2 = String.valueOf(Date.newInstance(Date.today().addDays(30).year(), Date.today().addDays(30).month(), Date.today().addDays(30).day()).format()).replace('/', '-');

        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/Product2/';
        request.addParameter('fecha1', fecha1);
        request.addParameter('fecha2', fecha2);
        request.addParameter('ciudadPartida', 'Medellín');
        request.addParameter('ciudadDestino', 'Bogota');
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        VueloRest.vueloWrapper result = VueloRest.getVuelos();
        // Verify results
        
        List<Product2> vuelitos = result.vuelitos; 
        String respuesta = result.mensaje;
        Boolean resultado = result.resultado;
        
        System.assert(vuelitos != null);
        System.assertEquals('La cuidad de llegada no tiene cobertura', respuesta);
        System.assertEquals(false, resultado);
    }
}