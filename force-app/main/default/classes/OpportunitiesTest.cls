@isTest
public class OpportunitiesTest {

	@isTest
    public static void OpportunitiesUpdateTest() {

        Integer bulkQuantity = 300;
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();

        //creamos un bulk de Opportunities
        for (Integer i = 0; i < bulkQuantity; i++) {

            Opportunity opp = new Opportunity();
            opp.Name = 'This is a test';
            opp.Start_Date__c = Date.today();
            opp.End_Date__c = Date.today().addDays(50);
            opp.CloseDate = Date.today();
            opp.StageName = 'Negotiation/Review';
            oppList.add(opp);

            //Para cada opportunity, creamos 3 items
            for (Integer j = 0; j < 3; j++) {
                OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
                oppLineItem.Opportunity__r = opp;

                if (Math.mod(j, 3) == 0) {
                	oppLineItem.Roles__c = 'Consultant';
                    oppLineItem.Quantity__c = 10;
                }
                else if (Math.mod(j, 3) == 1) {
                	oppLineItem.Roles__c = 'Developer';
                    oppLineItem.Quantity__c = 15;
                } 
                else if (Math.mod(j, 3) == 2) {
                	oppLineItem.Roles__c = 'Testing';
                    oppLineItem.Quantity__c = 6;
                }
				oppLineItemList.add(oppLineItem);
            }
        }
        insert oppList;

        //recorremos los oppLineItemList para actualizar su relación con la Opp
        for (OpportunityLineItem__c item : oppLineItemList) {
            item.Opportunity__c = item.Opportunity__r.Id;
        }
        insert oppLineItemList;

        //creamos un Map donde key=IdOpp, value=Opp
        Map<Id, Opportunity> oppsById = new Map<Id, Opportunity>();
        for (Opportunity opp : oppList) {
            oppsById.put(opp.Id, opp);
        }

        //ahora actualizamos la Stage de las Opp a 'Closed Won' y disparamos el trigger
        for (Opportunity opp : oppList) {
            opp.StageName = 'Closed Won';
        }
        Test.startTest();
        update oppList;
        Test.stopTest();

        //chequear creación de nuevos Project__c con información proveniente de las opp
        List<Project__c> newProjectsList =  [SELECT Id, Opportunity__c, Status__c, Start_Date__c, End_Date__c, Hours__c
                                             FROM Project__c WHERE Name = 'This is a test'];

        system.assertEquals(bulkQuantity, newProjectsList.size());
        for (Project__c newProject : newProjectsList) {
            Opportunity opp = oppsById.get(newProject.Opportunity__c);
            system.assertEquals(newProject.Opportunity__c, opp.Id);
            system.assertEquals(newProject.Start_Date__c, opp.Start_Date__c);
            system.assertEquals(newProject.End_Date__C, opp.End_Date__c);
            system.assertEquals(newProject.Status__c, 'Pre Kick-Off');
            system.assertEquals(newProject.Hours__c, 31);
        }

        Project__c newProject = newProjectsList[0];
		List<ProjectLineItem__c> newItems = [SELECT Id, Project__c FROM ProjectLineItem__c
                                             WHERE Project__r.Name = 'This is a test'
                                             ORDER BY Project__c];

        system.assertEquals(bulkQuantity*3, newItems.size());
    }
}