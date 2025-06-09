package SymbolTable;

public class SymbolInfo{
    
        private String name;
        private String type;
        private SymbolInfo next;
        private String printingLine;
    
        SymbolInfo(String name, String type,String print ){
            this.name = name;
            this.type = type;
            this.next = null;
            this.printingLine= print;
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