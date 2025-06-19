package SymbolTable;

import java.util.ArrayList;

public class SymbolInfo{
    
        private String name;
        private String type;
        private SymbolInfo next;
        private String printingLine;
        private String IDtype;
        public String returnType;
        public int paramNumber;
        public ArrayList<String> paramList;
        public String arrayType;

    
        public SymbolInfo(String name, String type,String print ){
            this.name = name;
            this.type = type;
            this.next = null;
            this.printingLine= print;
            this.IDtype="";
            this.returnType="";
            this.paramNumber = 0;
            paramList = new ArrayList<>();
            this.arrayType="";
            //cout<<printingLine<<endl;
        }
        public SymbolInfo(String name, String type,String print ,String IDtypee){
            this.name = name;
            this.type = type;
            this.next = null;
            this.printingLine= print;
            this.IDtype=IDtypee;
            this.returnType="";
            this.paramNumber = 0;
            paramList = new ArrayList<>();
            this.arrayType="";

            //cout<<printingLine<<endl;
        }
        public SymbolInfo(String name, String type) {
            this(name, type, "");
        }

        public String getName(){
            return this.name;
        }
        public void setName(String name){
            this.name = name;
        }
        public String getPrintingLine(){
            return this.printingLine;
        }
        public void setPrintingLine(String s){
            this.printingLine = s;
        }
        public String getType(){
            return this.type;
        }
        public void setType(String type){
            this.type = type;            
        }
        public void setIDType(String type){
            System.out.println("ID type being changedddd from "+this.IDtype+" to "+type);
            if(IDtype.equalsIgnoreCase("")){
                this.IDtype = type; 
            }              
        }
        public String getIDType(){
            return this.IDtype;            
        }
        public SymbolInfo getNext(){
            return this.next;
        }
        public void setNext(SymbolInfo next){
            this.next = next;
        }
        // void print(){
        //     cout<<"<"<<name<<","<<type<<
        // }
};