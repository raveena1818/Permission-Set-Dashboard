import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
import { LightningElement, track, api } from 'lwc';
import updatePermissionSet from '@salesforce/apex/objectPermissionController_sls.updatePermissionSet';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

export default class ObjectPermissionSet_sls extends LightningElement {
    @track acceptedFormats = ['.xls', '.xlsx'];
    @track fileData;
    @api objectList;

    columns = [
      {label:'S.No' , fieldName:'S_No'},
      {label:'Permission Set API Name', fieldName:'Permission_Set_API_Name'},
      {label:'Object', fieldName:'Object_API'},
      {label:'Read', fieldName:'Read', type:'boolean', editable:true},
      {label:'Create', fieldName:'Create', type:'boolean', editable:true},
      {label:'Edit', fieldName:'Edit', type:'boolean', editable:true},
      {label:'Delete', fieldName:'Delete', type:'boolean', editable:true},
      {label:'View All', fieldName:'View_All', type:'boolean', editable:true},
      {label:'Modify All', fieldName:'Modify_All', type:'boolean', editable:true}
    ]; 
    displayTable = false;
    sheet2List;
    sheetValidData = [];
    sheetErrors = [];
    @ track fieldList = [];
    allData = {};


    @track formattedData = {};

    combinations = [
      "false,false,false,false,false,false",
      "true,false,false,false,false,false", 
      "true,false,false,false,true,false", 
      "true,false,true,false,false,false",
      "true,false,true,false,true,false",
      "true,false,true,true,false,false",
      "true,false,true,true,true,false",
      "true,false,true,true,true,true",
      "true,true,false,false,false,false",
      "true,true,false,false,true,false",
      "true,true,true,false,false,false",
      "true,true,true,false,true,false",
      "true,true,true,true,false,false",
      "true,true,true,true,true,false",
      "true,true,true,true,true,true"

    ];


    
                connectedCallback(){
                console.log('object list data is '+this.objectList);
                this.sheet2List = this.objectList; 
                console.log('sheet2List is '+this.sheet2List);
                for(let i=0; i<this.sheet2List.length; i++)
                {
                  let str = this.sheet2List[i].Read+','+this.sheet2List[i].Create+','+this.sheet2List[i].Edit+','+this.sheet2List[i].Delete
                             +','+this.sheet2List[i].View_All+','+this.sheet2List[i].Modify_All;
                  
                  console.log('str is '+str);
                  
                  const result = this.combinations.includes(str);
                  console.log('result is '+result);
                //   if(result)
                //   {
                    console.log('inside if');
                  //  alert(JSON.stringify(this.sheet2List[i]));
                    this.sheet2List[i].valid = result;
                    this.sheetValidData.push(this.sheet2List[i]);
                    console.log('sheet valid data '+JSON.stringify(this.sheetValidData));
                 // }
                //   else
                //   {
                    // this.sheetErrors.push(this.sheet2List[i]);
                    // console.log('sheet Errors '+JSON.stringify(this.sheetErrors));
                 // }
                }

                this.displayTable = true;
              
                
              //  this.handleUpdatePermissionSet(this.formattedData);
            
        
    }
    

    exportWorksheet() {
     console.log('Export');
      var myFile = "JSONToExcel.xlsx";
      var myWorkSheet = XLSX.utils.json_to_sheet(JSON.parse(JSON.stringify(this.formattedData.Sheet1)));
      var myWorkBook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(myWorkBook, myWorkSheet, "myWorkSheet");
      XLSX.writeFile(myWorkBook, myFile);
      this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'Successfully downloaded',
            variant: 'success',
        }),
    );
    }

    onSave()
    {
      this.handleUpdatePermissionSet(this.formattedData);
    }

    handleUpdatePermissionSet(JsonData){
        updatePermissionSet({jsonFormattedData : JSON.stringify(JsonData)})
        .then(() => {
            console.log('result');
            this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Successfully Uploaded',
                        variant: 'success',
                    }),
                );
        })
        .catch(error => {
          console.log(error);
              this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                    }),
                );
        })
    }

  /*  for(let i=0; i<this.sheet2List.length; i++)
                {
                  let fields = {
                    SNo : this.sheet2List[i].S_No,
                    PermissionName : this.sheet2List[i].Permission_Set_API_Name,
                    ObjectAPI : this.sheet2List[i].Object_API,
                    Read : this.sheet2List[i].Read,
                    Create : this.sheet2List[i].Create,
                    Edit : this.sheet2List[i].Edit,
                    Delete : this.sheet2List[i].Delete,
                    ViewAll : this.sheet2List[i].View_All,
                    ModifyAll : this.sheet2List[i].Modify_All,
                    Id : Math.random()

                  };
                  this.allData.push(fields);
                }
                this.fieldList = JSON.parse(JSON.stringify(this.allData));
                console.log('field list is '+this.fieldList); */



}