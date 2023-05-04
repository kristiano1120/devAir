public with sharing class ReservaTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public ReservaTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
    }

    public void beforeInsert(List<Opportunity> newRecords) {
        // helper.doTask1();
        // helper.doTask2(); 
        actualizarFechaSiPagado(newRecords);
        NombreDeReserva(newRecords);       
    }
    public void beforeUpdate(List<Opportunity> oldRecords, List<Opportunity> newRecords, Map<ID, sObject> oldRecordMap, Map<ID, sObject> newRecordMap){
        // helper.doTask3();
        // helper.doTask4();
        actualizarFechaSiPagado(newRecords);
    }
    public void beforeDelete(List<Opportunity> oldRecords, Map<ID, sObject> oldOpportunityMap) {
        // helper.doTask5();
        // helper.doTask1();
    }
    public void afterInsert(List<Opportunity> newRecords, Map<ID, sObject> newOpportunityMap) {
        // helper.doTask2();
        // helper.doTask3();
    }
    public void afterUpdate(List<Opportunity> oldRecords, List<Opportunity> newRecords, Map<ID, sObject> oldOpportunityMap, Map<ID, sObject> newOpportunityMap) {
        // helper.doTask4();
        // helper.doTask5();
    }
    public void afterDelete(List<Opportunity> oldRecords, Map<ID, sObject> oldOpportunityMap) {
        // helper.doTask3();
        // helper.doTask1();
    }
    public void afterUndelete(List<Opportunity> newRecords, Map<ID, sObject> newOpportunityMap) {
        // helper.doTask4();
        // helper.doTask2();
    }

    //Si una reserva es pagada, actualizar fecha de pago y enviar correo al pasajero con la inf de su reserva.
    public static void actualizarFechaSiPagado(List<Opportunity> reserva){
        Set<Id> idContactos = new Set<Id>();
        for (Opportunity op : reserva) {
            idContactos.add(op.Titular_de_la_reserva__c);
        }
        Map<Id, Contact> titulares = new Map<Id, Contact>([SELECT id, Name, Email FROM Contact WHERE Id =: idContactos]); 

        for (Opportunity opp : reserva){
            if (opp.StageName == 'Pagado') {
                //Actualizar la fecha de pago
                opp.Fecha_de_pago__c = Date.today();
                

            }            
        }       
    }
    
    
    public static void NombreDeReserva(List<Opportunity> reservas) {
        set <Id> TitularesID = new set<Id>();
        for(Opportunity opp : reservas){
            TitularesID.add(opp.Titular_de_la_reserva__c);
        }
        Map<Id, Contact>  Titulares = new Map<Id, Contact>([SELECT Name FROM Contact WHERE Id = : TitularesID]);
        
        for (Opportunity opp : reservas) {
            if(String.isNotEmpty(opp.Name)){
                String NumeroDeReserva = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).substring(0,6);
                opp.Name = Titulares.get(opp.Titular_de_la_reserva__c).name + '-' + NumeroDeReserva;
                System.debug('nombre de reserva: '+ opp.Name);
            }
        }
    }
}