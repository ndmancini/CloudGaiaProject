@isTest
public with sharing class AllocatedResourceTriggerTest {

    @isTest
    public static void AllocatedResourceTriggerTest() {

        Integer Quantity= 60;

        List<Project__c> listProjects= new List<Project__c>();
        Project__c projectTest1= new Project__c();
        projectTest1.Name= 'Project Test';
        projectTest1.Start_Date__c=  Date.newInstance(2021, 09, 10);
        projectTest1.End_Date__c=  Date.newInstance(2021, 12, 10);
        projectTest1.Hours__c= 300;   
        projectTest1.Status__c= 'Pre Kick-Off';
        listProjects.add(projectTest1);

        Project__c projectTest2= new Project__c();
        projectTest2.Name= 'Project Test';
        projectTest2.Start_Date__c=  Date.newInstance(2021, 09, 25);
        projectTest2.End_Date__c=  Date.newInstance(2022, 01, 10);
        projectTest2.Hours__c= 500;   
        projectTest2.Status__c= 'Pre Kick-Off';
        listProjects.add(projectTest2);

        insert listProjects;

        List<ProjectLineItem__c> listProjectsItems= new List<ProjectLineItem__c>();
        for(Integer i=0; i<Quantity; i++){
            ProjectLineItem__c item= new ProjectLineItem__c();
            ProjectLineItem__c item2= new ProjectLineItem__c();
            if(math.mod(Quantity,2) == 0){
               item.Project__c= projectTest1.Id;
               item.Role__c= 'Developer';
               item2.Project__c= projectTest1.Id;
               item2.Role__c= 'Consultant';
               listProjectsItems.add(item);
               listProjectsItems.add(item2);
            }else{
                item.Project__c=projectTest2.Id;
                item.Role__c= 'Tester';
                item2.Project__c= projectTest2.Id;
                item2.Role__c= 'Marketing';
                listProjectsItems.add(item);
                listProjectsItems.add(item2);
            }
            
        }
        insert listProjectsItems;

        List<User> listUsers= new List<User>();

        List<Profile> profileId = [Select Id From Profile Where Name='Standard User'];
        for(Integer i=0; i<20; i++){
            User userTest= new User();
            userTest.Username= i+'testdePruebaCGP@gmail.com';
            userTest.LastName= 'Drago';
            userTest.Email= i+'test@gmail.com';
            userTest.Alias= i + 'test';
            userTest.TimeZoneSidKey='America/Tijuana';
            userTest.LocaleSidKey= 'en_US';
            userTest.LanguageLocaleKey= 'en_US';
            userTest.EmailEncodingKey= 'ISO-8859-1';
            userTest.ProfileId= profileId[0].Id;
            listUsers.add(userTest);
        }
        insert listUsers;

        List<User> allUsers= [SELECT Id FROM USER];
        List<ProjectLineItem__c> allItems=[SELECT id FROM ProjectLineItem__c];
        List<AllocatedResource__c> allocatedListOld= new List<AllocatedResource__c>();

        for(Integer i=0; i<10; i++){
            for(User user: allUsers){
                AllocatedResource__c allocated= new AllocatedResource__c();
                if(math.mod(Quantity,2) == 0){                    
                    allocated.Start_Date__c= Date.newInstance(2021, 09, 10);
                    allocated.End_Date__c= Date.newInstance(2021, 12, 10);
                    allocated.ProjectsItem__c= allItems[i].Id;
                    allocated.Resource__c= user.Id;
                    allocatedListOld.add(allocated);
                    break;
                }else{                    
                    allocated.Start_Date__c= Date.newInstance(2021, 09, 25);
                    allocated.End_Date__c= Date.newInstance(2022, 01, 10);
                    allocated.ProjectsItem__c= allItems[i].Id;
                    allocated.Resource__c= user.Id;
                    allocatedListOld.add(allocated);
                    break; 
                }
            }
        }
        insert allocatedListOld;

        List<AllocatedResource__c> allocatedList= new List<AllocatedResource__c>();
        for(Integer i=0; i<Quantity-10; i++){
            for(User user: allUsers){
                AllocatedResource__c allocated= new AllocatedResource__c();
                if(math.mod(Quantity,2) == 0){                    
                    allocated.Start_Date__c= Date.newInstance(2021, 09, 10);
                    allocated.End_Date__c= Date.newInstance(2021, 12, 10);
                    allocated.ProjectsItem__c= allItems[i].Id;
                    allocated.Resource__c= user.Id;
                    allocatedList.add(allocated);
                    break;
                }else{                    
                    allocated.Start_Date__c= Date.newInstance(2021, 09, 25);
                    allocated.End_Date__c= Date.newInstance(2022, 01, 10);
                    allocated.ProjectsItem__c= allItems[i].Id;
                    allocated.Resource__c= user.Id;
                    allocatedList.add(allocated);
                    break; 
                }
            }
        }
        insert allocatedList;

        List<AllocatedResource__c> listTest=[SELECT Id FROM AllocatedResource__c];
        system.assertEquals(Quantity,listTest.size());       
    }
}
