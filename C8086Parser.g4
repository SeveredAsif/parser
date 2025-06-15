parser grammar C8086Parser;

options {
    tokenVocab = C8086Lexer;
}

@header {
import java.io.BufferedWriter;
import java.io.IOException;
import SymbolTable.SymbolInfo;
}

@members {
    // helper to write into parserLogFile
    void writeIntoParserLogFile(String message) {
        try {
            Main.parserLogFile.write(message);
            Main.parserLogFile.newLine();
            Main.parserLogFile.flush();
        } catch (IOException e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }

    // helper to write into Main.errorFile
    void writeIntoErrorFile(String message) {
        try {
            Main.errorFile.write(message);
            Main.errorFile.newLine();
            Main.errorFile.flush();
        } catch (IOException e) {
            System.err.println("Error file write error: " + e.getMessage());
        }
    }
    

    void insertIntoSymbolTable(String name, String type){
        try {
            Main.st.insert(name,type);

        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }

    void insertIntoSymbolTable(String name, String type, String IDType){
        try {
            String printingLine = "< " + name + " : " + "ID" + " >";
            SymbolInfo sym = new SymbolInfo(name,type,printingLine,IDType); 
            Main.st.insert(sym);

        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }


    void enterNewScope(){
        try {
            Main.st.enterScope();
            Main.addToSymbolTable();
            

        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }
        
        
    void exitScope(){
        try {
            Main.addToSymbolTable();
            printSymboltable();
            Main.st.exitScope();

        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }
    void printSymboltable(){
        try {
            writeIntoParserLogFile(Main.st.getAllScopesAsString());
        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }
    }
    void addToPendingList(String name,String IDType){
        try {
            Main.addToPending(name,IDType);
        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }        
    }
    void addToPendingList(String name){
        try {
            Main.addToPending(name);
        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
        }        
    }

    boolean lookUp(String name){
        try {
            return Main.lookup(name);
        } catch (Exception e) {
            System.err.println("Parser log error: " + e.getMessage());
            return false;
        } 
     }

    String normalizeType(String rawType) {
        if (rawType == null) return null;
        switch (rawType.toUpperCase()) {
            case "CONST_INT":
                return "int";
            case "CONST_FLOAT":
                return "float";
            default:
                return rawType.toLowerCase(); 
        }
    }

}

start
    : p=program
      {
    writeIntoParserLogFile(
        "Line "+  $p.stop.getLine() + ": start : program\n"
    );         
        writeIntoParserLogFile(Main.st.getAllScopesAsString());
        writeIntoParserLogFile(
            "Total number of lines: "
            + $p.stop.getLine() 
        );
        writeIntoParserLogFile(
            "Total number of errors: "
            + Main.syntaxErrorCount
        );
    
      }
    ;

program
    returns [String name_line]
    : p=program u=unit
    {
    writeIntoParserLogFile(
        "Line "+  $u.stop.getLine() + ": program : program unit\n\n" + $p.name_line + "\n" + $u.name_line + "\n"
    ); 
    $name_line=$p.name_line + "\n" + $u.name_line;
    }
    | u=unit
    {
    writeIntoParserLogFile(
        "Line "+  $u.stop.getLine() + ": program : unit\n\n" + $u.name_line + "\n"
    ); 
    $name_line = $u.name_line;
    }
    
    ;

unit
    returns [String name_line]
    : v=var_declaration
    {
    writeIntoParserLogFile(
        "Line "+  $v.stop.getLine() + ": unit : var_declaration\n\n" + $v.name_line + "\n"
    ); 
    $name_line=$v.name_line;
    }
    | f=func_declaration
    {
    writeIntoParserLogFile(
        "Line "+  $f.stop.getLine() + ": unit : func_declaration\n\n" + $f.name_line + "\n"
    ); 
    $name_line=$f.name_line;
    }
    | f1=func_definition
    {
    writeIntoParserLogFile(
        "Line "+  $f1.stop.getLine() + ": unit : func_definition\n\n" + $f1.name_line + "\n"
    ); 
    $name_line=$f1.name_line;
    }
    ;

func_declaration
    returns [String name_line]
    : t=type_specifier ID LPAREN p=parameter_list RPAREN sm=SEMICOLON
      {
        writeIntoParserLogFile(
            "Line "
            + $sm.getLine() + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" +$t.text + " "+ $ID.getText() + "(" + $p.name_line +")"+ ";\n"
        ); 
        $name_line=$t.text + " "+ $ID.getText() + "(" + $p.name_line +");";    
   
        Main.st.insert($ID.getText(),"ID");
        Main.pendingInsertions.clear();
      }
    | t=type_specifier ID LPAREN RPAREN sm=SEMICOLON
      {
        writeIntoParserLogFile(
            "Line "
            + $sm.getLine() + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n" +$t.text + " "+ $ID.getText() + "()"+ ";\n"
        );   
        $name_line = $t.text + " "+ $ID.getText() + "();";         
        Main.st.insert($ID.getText(),"ID");
        Main.pendingInsertions.clear();
      }
    ;

func_definition
    returns [String name_line]
    : t=type_specifier 
    ID
    {
        Main.st.insert($ID.getText(),"ID");    
    } 
    LPAREN p=parameter_list RPAREN c=compound_statement
    {
        writeIntoParserLogFile(
            "Line "
            + $c.stop.getLine() + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" +$t.text + " "+ $ID.getText() + "("+$p.name_line+ ")"+ $c.name_line + "\n"
        );          
        $name_line = $t.text + " "+ $ID.getText() + "("+$p.name_line+ ")"+ $c.name_line;
        Main.st.insert($ID.getText(),"ID");

    }
    | t=type_specifier 
    ID
    {
        Main.st.insert($ID.getText(),"ID");
    } 
    LPAREN RPAREN c=compound_statement
    {
        writeIntoParserLogFile(
            "Line "
            + $c.stop.getLine() + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" +$t.text + " "+ $ID.getText() + "()"+ $c.name_line + "\n"
        );          
        $name_line = $t.text + " "+ $ID.getText() + "()"+ $c.name_line;
    }
    ;

parameter_list
    returns [String name_line]
    : p=parameter_list COMMA t=type_specifier ID
    {
        
        boolean alreadyDeclared = false;
        for (SymbolInfo si : Main.pendingInsertions) {
            if (si.getName().equals($ID.getText())) {
                alreadyDeclared = true;
                break;
            }
        }

        if (alreadyDeclared) {
            Main.syntaxErrorCount++;
            writeIntoParserLogFile(
                "Error at line " + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + " in parameter\n"
            ); 
            writeIntoErrorFile(
                "Error at line " + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + " in parameter\n"
            );           
        } else {
            addToPendingList($ID.getText(), $t.text);
        }
      
        writeIntoParserLogFile(
            "Line "
            + $ID.getLine() + ": parameter_list : parameter_list COMMA type_specifier ID\n\n" + $p.name_line + ","+ $t.text + " " + $ID.getText() + "\n"
        );          
        $name_line = $p.name_line + ","+ $t.text + " " + $ID.getText();
    //addToPendingList($ID.getText(),$t.text);  
    }
    | p=parameter_list COMMA t=type_specifier
    {
        writeIntoParserLogFile(
            "Line "
            + $t.stop.getLine() + ": parameter_list : parameter_list COMMA type_specifier\n\n" + $p.name_line + ","+ $t.text + "\n"
        );          
        $name_line = $p.name_line + ","+ $t.text;
    }
    | t=type_specifier ID
    {
        boolean alreadyDeclared = false;
        for (SymbolInfo si : Main.pendingInsertions) {
            if (si.getName().equals($ID.getText())) {
                alreadyDeclared = true;
                break;
            }
        }

        if (alreadyDeclared) {
            Main.syntaxErrorCount++;
            writeIntoParserLogFile(
                "Error at line " + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + " in parameter\n"
            ); 
            writeIntoErrorFile(
                "Error at line " + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + " in parameter\n"
            );           
        } else {
            addToPendingList($ID.getText(), $t.text);
        }       
        writeIntoParserLogFile(
            "Line "
            + $t.stop.getLine() + ": parameter_list : type_specifier ID\n\n" + $t.text + " " + $ID.getText() + "\n"
        );          
        $name_line = $t.text + " " + $ID.getText();
        // addToPendingList($ID.getText(),$t.text);  
    }
    | t=type_specifier
    {
        writeIntoParserLogFile(
            "Line "
            + $t.stop.getLine() + ": parameter_list : type_specifier \n\n" + $t.text + "\n"
        );          
        $name_line = $t.text ;
    }
    ;

compound_statement 
    returns [String name_line]
    : LCURL 
    {
        enterNewScope();
    }
    stmts=statements 
    RCURL
    {
        
        writeIntoParserLogFile(
            "Line " + $RCURL.getLine() + ": compound_statement : LCURL statements RCURL\n\n{\n" + $stmts.name_line + "\n}\n"
        );
        $name_line = "{\n" + $stmts.name_line + "\n}";
        exitScope();
    }
    | LCURL RCURL
    {
        writeIntoParserLogFile(
            "Line " + $RCURL.getLine() + ": compound_statement : LCURL RCURL\n\n{}\n"
        );
        $name_line = "{}";
    }
    ;


var_declaration
    returns [String name_line]
    : t=type_specifier dl=declaration_list sm=SEMICOLON
      {
        writeIntoParserLogFile(
            "Line "
            + $sm.getLine() + ": var_declaration : type_specifier declaration_list SEMICOLON\n\n" + $t.text +  " " + $dl.text + ";\n"
        );
        $name_line = $t.text +  " " + $dl.text+";";   
        Main.addToSymbolTable($t.text);        
      }
    | t=type_specifier de=declaration_list_err sm=SEMICOLON
      {
        writeIntoErrorFile(
            "Line# "
            + $sm.getLine()
            + " with error name: "
            + $de.error_name
            + " - Syntax error at declaration list of variable declaration"
        );
        //Main.syntaxErrorCount++;
      }
    ;

declaration_list_err
    returns [String error_name]
    : { $error_name = "Error in declaration list"; }
    ;

type_specifier
    returns [String name_line]
    : INT
      {
        writeIntoParserLogFile(
            "Line "
            + $INT.getLine() + ": type_specifier : INT\n\n" + $INT.getText() + "\n"
        );        
        $name_line = "type: INT at line" + $INT.getLine();
      }
    | FLOAT
      {
        writeIntoParserLogFile(
            "Line "
            + $FLOAT.getLine() + ": type_specifier : FLOAT\n\n" + $FLOAT.getText() + "\n"
        );              
        $name_line = "type: FLOAT at line" + $FLOAT.getLine();
      }
    | VOID
      {
        writeIntoParserLogFile(
            "Line "
            + $VOID.getLine() + ": type_specifier : VOID\n\n" + $VOID.getText() + "\n"
        );              
        $name_line = "type: VOID at line" + $VOID.getLine();
      }
    ;

declaration_list
    : dec1=declaration_list COMMA ID
    {
        boolean b = lookUp($ID.getText());
        if(b==true){
            Main.syntaxErrorCount++;
        writeIntoParserLogFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"
        ); 
        writeIntoErrorFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"            
        );             
        }       
        
        writeIntoParserLogFile(
            "Line "
            + $ID.getLine() + ": declaration_list : declaration_list COMMA ID\n\n" + $dec1.text + ","+$ID.getText() + "\n"
        );   
    addToPendingList($ID.getText());  
    //insertIntoSymbolTable($ID.getText(),"ID");     
    }
    | dec2=declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
    {
        
        boolean b = lookUp($ID.getText());
        if(b==true){
            Main.syntaxErrorCount++;
        writeIntoParserLogFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"
        );  
        writeIntoErrorFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"            
        );            
        }       
        writeIntoParserLogFile(
            "Line "
            + $ID.getLine() + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" + $dec2.text+","+$ID.getText()+"["+$CONST_INT.getText() + "]\n"
        );  
        addToPendingList($ID.getText(),"array"); 
        //insertIntoSymbolTable($ID.getText(),"ID","array"); 
    }
    | ID
    {
        boolean b = lookUp($ID.getText());
        if(b==true){
            Main.syntaxErrorCount++;
        writeIntoParserLogFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"
        );      
        writeIntoErrorFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"            
        );        
        }
        writeIntoParserLogFile(
            "Line "
            + $ID.getLine() + ": declaration_list : ID\n\n" + $ID.getText() + "\n"
        );
        addToPendingList($ID.getText());            
    }
    | ID LTHIRD CONST_INT RTHIRD
    {
        
        boolean b = lookUp($ID.getText());
        if(b==true){
            Main.syntaxErrorCount++;
        writeIntoParserLogFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"
        );        
        writeIntoErrorFile(
            "Error at line "
            + $ID.getLine() + ": Multiple declaration of " + $ID.getText() + "\n"            
        );      
        }       
        writeIntoParserLogFile(
            "Line "
            + $ID.getLine() + ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n" + $ID.getText() + "[" + $CONST_INT.getText()+ "]\n"
        );  
        addToPendingList($ID.getText(),"array");          
    }
    ;

statements 
    returns [String name_line]
    : s=statement
    {
        writeIntoParserLogFile(
            "Line " + $s.stop.getLine() + ": statements : statement\n\n" + $s.name_line + "\n"
        );
        $name_line = $s.name_line;
    }
    | s1=statements s2=statement
    {
        writeIntoParserLogFile(
            "Line " + $s2.stop.getLine() + ": statements : statements statement\n\n" + $s1.name_line + "\n" + $s2.name_line + "\n"
        );
        $name_line = $s1.name_line + "\n" + $s2.name_line;
    }
    ;


statement returns [String name_line]
    : v=var_declaration
    {
        writeIntoParserLogFile(
            "Line " + $v.stop.getLine() + ": statement : var_declaration\n\n" + $v.name_line + "\n"
        );
        $name_line = $v.name_line;
    }
    | ex=expression_statement
    {
        writeIntoParserLogFile(
            "Line " + $ex.stop.getLine() + ": statement : expression_statement\n\n" + $ex.name_line + "\n"
        );
        $name_line = $ex.name_line;
    }
    | c=compound_statement
    {
        writeIntoParserLogFile(
            "Line " + $c.stop.getLine() + ": statement : compound_statement\n\n" + $c.name_line + "\n"
        );
        $name_line = $c.name_line;
    }
    | FOR LPAREN e1=expression_statement e2=expression_statement e3=expression RPAREN s=statement
    {
        writeIntoParserLogFile(
            "Line " + $s.stop.getLine() + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n"
            + "for(" + $e1.name_line + "" + $e2.name_line + "" + $e3.name_line + ")" + $s.name_line + "\n"
        );
        $name_line = "for(" + $e1.name_line + "" + $e2.name_line + "" + $e3.name_line + ")" + $s.name_line;
    }
    | IF LPAREN e=expression RPAREN s=statement
    {
        writeIntoParserLogFile(
            "Line " + $s.stop.getLine() + ": statement : IF LPAREN expression RPAREN statement\n\n"
            + "if(" + $e.name_line + ")" + $s.name_line + "\n"
        );
        $name_line = "if(" + $e.name_line + ")" + $s.name_line;
    }
    | IF LPAREN e=expression RPAREN s1=statement ELSE s2=statement
    {
        writeIntoParserLogFile(
            "Line " + $s2.stop.getLine() + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n"
            + "if(" + $e.name_line + ")" + $s1.name_line + "else " + $s2.name_line + "\n"
        );
        $name_line = "if(" + $e.name_line + ")" + $s1.name_line + "else " + $s2.name_line;
    }
    | WHILE LPAREN e=expression RPAREN s=statement
    {
        writeIntoParserLogFile(
            "Line " + $s.stop.getLine() + ": statement : WHILE LPAREN expression RPAREN statement\n\n"
            + "while(" + $e.name_line + ")" + $s.name_line + "\n"
        );
        $name_line = "while(" + $e.name_line + ")" + $s.name_line;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON
    {
        writeIntoParserLogFile(
            "Line " + $SEMICOLON.getLine() + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n"
            + "printf(" + $ID.getText() + ");\n"
        );
        $name_line = "printf(" + $ID.getText() + ");";
    }
    | RETURN e=expression SEMICOLON
    {
        writeIntoParserLogFile(
            "Line " + $SEMICOLON.getLine() + ": statement : RETURN expression SEMICOLON\n\n"
            + "return " + $e.name_line + ";\n"
        );
        $name_line = "return " + $e.name_line + ";";
    }
    ;


expression_statement 
    returns [String name_line]
    : SEMICOLON
    {
        writeIntoParserLogFile(
            "Line " + $SEMICOLON.getLine() + ": expression_statement : SEMICOLON\n\n;\n"
        );
        $name_line = ";";
    }
    | ex=expression SEMICOLON
    {
        writeIntoParserLogFile(
            "Line " + $SEMICOLON.getLine() + ": expression_statement : expression SEMICOLON\n\n" + $ex.name_line + ";\n"
        );
        $name_line = $ex.name_line + ";";
    }
    ;


variable
    returns [String name_line]
    : ID
    {
        writeIntoParserLogFile(
        "Line "
        + $ID.getLine() + ": variable : ID\n" 
    );    
    $name_line=$ID.getText();   
    if(Main.st.lookup($ID.getText())==null){
            Main.syntaxErrorCount++;
            writeIntoParserLogFile("Error at line " + $ID.getLine() + ": Undeclared variable " + $ID.getText() + "\n");
            writeIntoErrorFile("Error at line " + $ID.getLine() + ": Undeclared variable " + $ID.getText() + "\n");
    }  
    if(Main.st.lookup($ID.getText())!=null){
        
        if(Main.st.lookup($ID.getText()).getIDType().equalsIgnoreCase("array")){
            Main.syntaxErrorCount++;
            writeIntoParserLogFile("Error at line " + $ID.getLine() + ": Type mismatch, " + $ID.getText() + " is an array\n");
            writeIntoErrorFile("Error at line " + $ID.getLine() + ": Type mismatch, " + $ID.getText() + " is an array\n");
        }
        
        for (SymbolInfo sym : Main.pendingInsertions) {
            if (sym.getName().equals($ID.getText())) {
                if (sym.getIDType().equalsIgnoreCase("array")) {
                    Main.syntaxErrorCount++;
                    writeIntoParserLogFile("Error at line " + $ID.getLine() + ": Type mismatch, " + $ID.getText() + " is an array\n");
                    writeIntoErrorFile("Error at line " + $ID.getLine() + ": Type mismatch, " + $ID.getText() + " is an array\n");
                }
                break; 
            }
        }
    }
    

    writeIntoParserLogFile($ID.getText()+"\n");

    //addToPendingList($ID.getText());
    }
    | ID LTHIRD e=expression RTHIRD
    {
        writeIntoParserLogFile(
        "Line "
        + $ID.getLine() + ": variable : ID LTHIRD expression RTHIRD\n" 
    );

        if(!$e.type.equalsIgnoreCase("CONST_INT")){
        Main.syntaxErrorCount++;
        writeIntoParserLogFile(
            "Error at line "
            + $ID.getLine() + ": Expression inside third brackets not an integer\n"
        ); 
        writeIntoErrorFile(
            "Error at line "
            + $ID.getLine() + ": Expression inside third brackets not an integer\n"        
        );  
        } 

        writeIntoParserLogFile(
            $ID.getText() + "[" + $e.name_line+ "]\n"
        );

    $name_line=$ID.getText() + "[" + $e.name_line+ "]";  
   // addToPendingList($ID.getText());      
    }
    ;

expression
    returns [String name_line,String type]
    : l=logic_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $l.stop.getLine() + ": expression : logic_expression\n\n" + $l.name_line +"\n"
    );        
    $name_line =$l.name_line;
    $type = $l.type;
    }
    | v=variable a=ASSIGNOP l=logic_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $l.stop.getLine() + ": expression : variable ASSIGNOP logic_expression\n" 
    );          
        $name_line=$v.name_line+""+ $a.text + "" + $l.name_line;
        if(Main.st.lookup($v.name_line)!=null){
            String IDtokenType = Main.st.lookup($v.name_line).getIDType();
            if(!IDtokenType.equalsIgnoreCase(normalizeType($l.type)) && !IDtokenType.equalsIgnoreCase("array") && $l.type!=null){
                if(!(IDtokenType.equalsIgnoreCase("float") && normalizeType($l.type).equalsIgnoreCase("int"))){
                    Main.syntaxErrorCount++;
                    writeIntoParserLogFile("Error at line "  + $l.stop.getLine() + ": Type Mismatch\n");
                    writeIntoErrorFile("Error at line " +  $l.stop.getLine() + ": Type Mismatch\n");
                 }
            }
        }
        writeIntoParserLogFile(
            $v.name_line+""+ $a.text + "" + $l.name_line +"\n"
        );
    }
    ;

logic_expression
    returns [String name_line,String type]
    : r=rel_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $r.stop.getLine() + ": logic_expression : rel_expression\n\n" + $r.name_line +"\n"
    );
        $name_line=$r.name_line;
        $type = $r.type;
    }
    | r=rel_expression LOGICOP re=rel_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $re.stop.getLine() + ": logic_expression : rel_expression LOGICOP rel_expression\n\n" + $r.name_line+ "" + $LOGICOP.getText() + "" + $re.name_line +"\n"
    );          
        $name_line=$r.name_line+ "" + $LOGICOP.getText() + "" + $re.name_line;
    }
    ;

rel_expression
    returns [String name_line,String type]
    : s=simple_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $s.stop.getLine() + ": rel_expression : simple_expression\n\n" + $s.name_line +"\n"
    );
        $name_line=$s.name_line;
        $type = $s.type;
    }
    | s=simple_expression RELOP s1=simple_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $s1.stop.getLine() + ": rel_expression : simple_expression RELOP simple_expression\n\n" + $s.name_line +"" +$RELOP.getText() +""+$s1.name_line +"\n"
    );
        $name_line=$s.name_line +"" +$RELOP.getText()+""+$s1.name_line;
    }
    ;

simple_expression
    returns [String name_line,String type]
    : t=term
    {
        writeIntoParserLogFile(
        "Line "
        + $t.stop.getLine() + ": simple_expression : term\n\n" + $t.name_line +"\n"
    );
        $name_line=$t.name_line;
        $type = $t.type;
    }
    | s=simple_expression ADDOP t=term
    {
        writeIntoParserLogFile(
        "Line "
        + $t.stop.getLine() + ": simple_expression : simple_expression ADDOP term\n\n" +$s.name_line+""+$ADDOP.getText()+"" +$t.name_line +"\n"
    );
        $name_line=$s.name_line+""+$ADDOP.getText()+"" +$t.name_line;
    }    
    ;

term
    returns [String name_line,String type]
    : u=unary_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $u.stop.getLine() + ": term : unary_expression\n\n" +$u.name_line +"\n"
    );
        $name_line=$u.name_line;
        $type=$u.type;
    }
    | t=term MULOP u=unary_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $u.stop.getLine() + ": term : term MULOP unary_expression\n" 
    );

        
        if($u.type!=null){
                if(!$u.type.equalsIgnoreCase("CONST_INT")){
                    Main.syntaxErrorCount++;
                    writeIntoParserLogFile(
                    "Error at line "
                    + $u.stop.getLine() + ": Non-Integer operand on modulus operator" +"\n"
                ); 
                    writeIntoErrorFile(
                    "Error at line "
                    + $u.stop.getLine() + ": Non-Integer operand on modulus operator" +"\n"
                );       
            }
        }


    writeIntoParserLogFile($t.name_line+""+$MULOP.getText()+"" +$u.name_line +"\n");     
        $name_line=$t.name_line+""+$MULOP.getText()+"" +$u.name_line;
    }
    ;

unary_expression
    returns [String name_line, String type]
    : ADDOP u=unary_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $u.stop.getLine() + ": unary_expression : ADDOP unary_expression\n\n" + $ADDOP.getText()+"" +$u.name_line +"\n"
    );
        $name_line=$ADDOP.getText()+"" +$u.name_line;
    }
    | NOT u=unary_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $u.stop.getLine() + ": unary_expression : NOT unary_expression\n\n" +$NOT.getText()+"" +$u.name_line +"\n"
    );
        $name_line=$NOT.getText()+"" +$u.name_line;
    }
    | f=factor
    {
        writeIntoParserLogFile(
        "Line "
        + $f.stop.getLine() + ": unary_expression : factor\n\n" +$f.name_line +"\n"
    );
        $name_line=$f.name_line;
        $type=$f.type;
    }
    ;

factor
    returns [String name_line,String type]
    : v=variable
    {
        writeIntoParserLogFile(
        "Line "
        + $v.stop.getLine() + ": factor : variable\n\n" +$v.name_line +"\n"
    );
        $name_line=$v.name_line;
    }
    | ID LPAREN a=argument_list RPAREN
    {
        writeIntoParserLogFile(
        "Line "
        + $RPAREN.getLine() + ": factor : ID LPAREN argument_list RPAREN\n\n" +$ID.getText()+"(" +$a.name_line +")\n"
    );
        $name_line=$ID.getText()+"(" +$a.name_line +")";
    }
    | LPAREN e=expression RPAREN
    {
        writeIntoParserLogFile(
        "Line "
        + $RPAREN.getLine() + ": factor : LPAREN expression RPAREN\n\n" +"(" +$e.name_line +")\n"
    );
        $name_line="(" +$e.name_line +")";
    }
    | CONST_INT
    {
        writeIntoParserLogFile(
        "Line "
        + $CONST_INT.getLine() + ": factor : CONST_INT\n\n" +$CONST_INT.getText() +"\n"
    );
        $name_line=$CONST_INT.getText();
        $type="CONST_INT";
    }
    | CONST_FLOAT
    {
        writeIntoParserLogFile(
        "Line "
        + $CONST_FLOAT.getLine() + ": factor : CONST_FLOAT\n\n" +$CONST_FLOAT.getText() +"\n"
    );
        $name_line=$CONST_FLOAT.getText();
        $type="CONST_FLOAT";
    }
    | v=variable INCOP
    {
        writeIntoParserLogFile(
        "Line "
        + $INCOP.getLine() + ": factor : variable INCOP\n\n" +$v.name_line +$INCOP.getText() +"\n"
    );
        $name_line=$v.name_line +$INCOP.getText();
    }
    | v=variable DECOP
    {
        writeIntoParserLogFile(
        "Line "
        + $DECOP.getLine() + ": factor : variable DECOP\n\n" +$v.name_line +$DECOP.getText() +"\n"
    );
        $name_line=$v.name_line +$DECOP.getText();
    }
    ;

argument_list
returns [String name_line]
    : a=arguments
    {
        writeIntoParserLogFile(
        "Line "
        + $a.stop.getLine() + ": argument_list : arguments\n\n" +$a.name_line +"\n"
    );
        $name_line=$a.name_line;
    }
    | /* empty */
    ;

arguments
    returns [String name_line]
    : a=arguments COMMA l=logic_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $l.stop.getLine() + ": arguments : arguments COMMA logic_expression\n\n" +$a.name_line + "," + $l.name_line +"\n"
    );
        $name_line=$a.name_line + "," + $l.name_line;
    }
    | l1=logic_expression
    {
        writeIntoParserLogFile(
        "Line "
        + $l1.stop.getLine() + ": arguments : logic_expression\n\n" +$l1.name_line +"\n"
    );
        $name_line=$l1.name_line;
    }
    ;
