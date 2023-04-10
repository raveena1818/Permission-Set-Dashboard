public with sharing class objectPermissionController_sls {

    @AuraEnabled
    public static void updatePermissionSet(string jsonFormattedData) {
        
        Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(jsonFormattedData);
   
        system.debug(data);
        
        List<Object> listOfSheet1Data = (List<Object>)data.get('Sheet1');
        List<Object> listofSheet2Data = (List<Object>)data.get('Sheet2');
        List<Object> listofSheet3Data = (List<Object>)data.get('Sheet3');
        system.debug('listOfSheet1Data ' + listOfSheet1Data);
         system.debug('listofSheet2Data ' + listofSheet2Data);
         system.debug('listofSheet3Data ' + listOfsheet3Data);
        
        set<string> permissionSetNames = new set<string>();
        set<string> sobjectTypes = new set<string>();
        set<string> psIds = new set<string>();
        set<string> apexApi = new set<string>();
 
     // new code
        set<string> permissionSetNamesObj = new set<string>();
        set<string> sobjectTypesObj = new set<string>();
 
        for(Object sheetData : listOfSheet1Data){
            Map<String,Object> rowData = (Map<String,Object>)sheetData;
            permissionSetNames.add((String)rowData.get('Permission_Set_API_Name'));
            sobjectTypes.add((String)rowData.get('Object_API')+'.'+(String)rowData.get('Field_API'));
        }
 
     // new code
        for(Object sheetData : listofSheet2Data)
        {
         Map<String, Object> rowData = (Map<String, Object>)sheetData;
         system.debug('row data is '+ rowData);
         permissionSetNamesObj.add((String)rowData.get('Permission_Set_API_Name'));
         system.debug('permission Set names '+permissionSetNamesObj);
         sobjectTypesObj.add((String)rowData.get('Object_API'));
         system.debug('sobject types '+sobjectTypesObj);
 
        }
 
        set<Id> obIds = new set<Id>();
        List<PermissionSet> pSet =[select Id,Name, LastModifiedDate, CreatedDate, CreatedBy.Name,ProfileId,SystemModstamp FROM PermissionSet where Name IN :permissionSetNamesObj];
        system.debug('ps is '+pSet);
        for(PermissionSet p : pSet)
        {
        obIds.add(p.Id);
     }
        system.debug('obIds is '+obIds);
 
        List<ObjectPermissions> objectPermissionsList = [Select ID, ParentId, SobjectType, PermissionsEdit, PermissionsRead, PermissionsDelete, PermissionsCreate, PermissionsModifyAllRecords, PermissionsViewAllRecords FROM ObjectPermissions WHERE SobjectType IN :sobjectTypesObj and ParentId IN :obIds];
        system.debug('object permissions '+objectPermissionsList);
 
        List<ObjectPermissions> objToInsert = new List<ObjectPermissions>();
        Map<string, ObjectPermissions> objectPermissionsMap = new Map<string, ObjectPermissions>();
        Map<string, ObjectPermissions> objectPermissionsMapName = new Map<string, ObjectPermissions>();
        Map<string, ObjectPermissions> objectPermissionsFetch = new Map<string, ObjectPermissions>();
        for(ObjectPermissions op : objectPermissionsList)
        {
         objectPermissionsMap.put(op.ParentId, op);
         objectPermissionsMapName.put(op.SobjectType, op);
         objectPermissionsFetch.put(op.ParentId +',' + op.SobjectType, op);
        }
        system.debug('objectPermissionFetch is '+objectPermissionsFetch);
        if(listofSheet2Data!=null && listofSheet2Data.size()>0)
        {
          for(object sheetData : listofSheet2Data)
          {
             Map<String,Object> rowData = (Map<String,Object>)sheetData;
             for(PermissionSet ps : pSet){
                 ObjectPermissions op = new ObjectPermissions();
                 if(ps.Name == (String)rowData.get('Permission_Set_API_Name'))
                 {
                 op.parentid = ps.Id;
                 system.debug('parent id '+op.parentid);
                 op.SobjectType = (String)rowData.get('Object_API');
                 system.debug('sobject type is '+op.SobjectType);
                 if(objectPermissionsMapName.containsKey((String)rowData.get('Object_API'))
                      && objectPermissionsMap.containsKey(ps.Id) && objectPermissionsFetch.containsKey(ps.id+','+(String)rowData.get('Object_API')))
                 {
                 system.debug('inside if');
                 op.Id = objectPermissionsFetch.get(ps.id+','+(String)rowData.get('Object_API')).Id;
                 }
                 system.debug('Id is '+op.Id);
                 
              /*  if((String)rowData.get('Read')== 'true' && (String)rowData.get('Create')== 'false' && (String)rowData.get('Edit')== 'false' 
                 && (String)rowData.get('Delete')== 'false' && (String)rowData.get('View All')== 'false' && (String)rowData.get('Modify All')== 'false')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false; 
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Create')== 'true' && (String)rowData.get('Read')== 'true' && (String)rowData.get('Edit')== 'false' 
                 && (String)rowData.get('Delete')== 'false' && (String)rowData.get('View All')== 'false' && (String)rowData.get('Modify All')== 'false')
                 {
                 op.PermissionsCreate = true;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Edit')== 'true' && (String)rowData.get('Create')== 'false' && (String)rowData.get('Read')== 'true'
                 && (String)rowData.get('Delete')== 'false' && (String)rowData.get('View All')== 'false' && (String)rowData.get('Modify All')== 'false')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Delete')== 'true' && (String)rowData.get('Create')== 'false' && (String)rowData.get('Read')== 'true'
                 && (String)rowData.get('Edit')== 'true' && (String)rowData.get('View All')== 'false' && (String)rowData.get('Modify All')== 'false')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = true;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('View All')== 'true' && (String)rowData.get('Create')== 'false' && (String)rowData.get('Read')== 'true'
                 && (String)rowData.get('Edit')== 'false' && (String)rowData.get('Delete')== 'false' && (String)rowData.get('Modify All')== 'false')
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = false;
                     op.PermissionsDelete = false;
                     op.PermissionsModifyAllRecords = false;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 }
                 else if((String)rowData.get('Modify All')== 'true' && (String)rowData.get('Create')== 'false' && (String)rowData.get('Read')== 'true'
                 && (String)rowData.get('Edit')== 'true' && (String)rowData.get('Delete')== 'true' && (String)rowData.get('View All')== 'true')
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = true;
                     op.PermissionsDelete = true;
                     op.PermissionsModifyAllRecords = true;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 }  */
 
                 // with boolean
                 if((Boolean)rowData.get('Read')== TRUE && (Boolean)rowData.get('Create')== FALSE && (Boolean)rowData.get('Edit')== FALSE
                 && (Boolean)rowData.get('Delete')== FALSE && (Boolean)rowData.get('View_All')== FALSE && (Boolean)rowData.get('Modify_All')== FALSE)
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false; 
                 objToInsert.add(op);
                 }
                 else if((Boolean)rowData.get('Create')== TRUE && (Boolean)rowData.get('Read')== TRUE && (Boolean)rowData.get('Edit')== FALSE
                 && (Boolean)rowData.get('Delete')== FALSE && (Boolean)rowData.get('View_All')== FALSE && (Boolean)rowData.get('Modify_All')== FALSE)
                 {
                 op.PermissionsCreate = true;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((Boolean)rowData.get('Edit')== TRUE && (Boolean)rowData.get('Create')== FALSE && (Boolean)rowData.get('Read')== TRUE
                 && (Boolean)rowData.get('Delete')== FALSE && (Boolean)rowData.get('View_All')== FALSE && (Boolean)rowData.get('Modify_All')== FALSE)
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((Boolean)rowData.get('Delete')== TRUE && (Boolean)rowData.get('Create')== FALSE && (Boolean)rowData.get('Read')== TRUE
                 && (Boolean)rowData.get('Edit')== TRUE && (Boolean)rowData.get('View_All')== FALSE && (Boolean)rowData.get('Modify_All')== FALSE)
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = true;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((Boolean)rowData.get('View_All')== TRUE && (Boolean)rowData.get('Create')== FALSE && (Boolean)rowData.get('Read')== TRUE
                 && (Boolean)rowData.get('Edit')== FALSE && (Boolean)rowData.get('Delete')== FALSE && (Boolean)rowData.get('Modify_All')== FALSE)
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = false;
                     op.PermissionsDelete = false;
                     op.PermissionsModifyAllRecords = false;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 }
                 else if((Boolean)rowData.get('Modify_All')== TRUE && (Boolean)rowData.get('Create')== FALSE && (Boolean)rowData.get('Read')== TRUE
                 && (Boolean)rowData.get('Edit')== TRUE && (Boolean)rowData.get('Delete')== TRUE && (Boolean)rowData.get('View_All')== TRUE)
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = true;
                     op.PermissionsDelete = true;
                     op.PermissionsModifyAllRecords = true;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 } 
                
                 
                 // With single Access
 
             /*   if((String)rowData.get('Access')== 'Read')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false; 
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Access')== 'Create')
                 {
                 op.PermissionsCreate = true;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = false;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Access')== 'Edit')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = false;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Access')== 'Delete')
                 {
                 op.PermissionsCreate = false;
                 op.PermissionsRead   = true;
                 op.PermissionsEdit   = true;
                 op.PermissionsDelete = true;
                 op.PermissionsModifyAllRecords = false;
                 op.PermissionsViewAllRecords = false;
                 objToInsert.add(op);
                 }
                 else if((String)rowData.get('Access')== 'View_All')
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = false;
                     op.PermissionsDelete = false;
                     op.PermissionsModifyAllRecords = false;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 }
                 else if((String)rowData.get('Access')== 'Modify_All')
                 {
                     op.PermissionsCreate = false;
                     op.PermissionsRead   = true;
                     op.PermissionsEdit   = true;
                     op.PermissionsDelete = true;
                     op.PermissionsModifyAllRecords = true;
                     op.PermissionsViewAllRecords = true;
                     objToInsert.add(op);
                 } */
                
 
                
 
                 }
             }
 
          }
        }
 
        system.debug('objToInsert ' +objToInsert);
        upsert objToInsert;
     }  
   
}