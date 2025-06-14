import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

import SymbolTable.SymbolInfo;
import SymbolTable.SymbolTable;

public class Main {
    public static BufferedWriter parserLogFile;
    public static BufferedWriter errorFile;
    public static BufferedWriter lexLogFile;
    public static SymbolTable st;

    public static int syntaxErrorCount = 0;
    public static List<SymbolInfo> pendingInsertions;
    public static void addToPending(String name,String IDType){
        String print = "< " + name + " : " + "ID" + " >";
        SymbolInfo sym = new SymbolInfo(name, "ID",print,IDType);
        //sym.setPrintingLine();
        //sym.IDtype = IDType;
        //sym.setIDType(IDType);
        pendingInsertions.add(sym);
        System.out.println("ID name: "+sym.getName()+" ID Type: "+sym.getIDType());
    }
    public static void addToPending(String name){
        SymbolInfo sym = new SymbolInfo(name, "ID");
        sym.setPrintingLine("< " + name + " : " + "ID" + " >");
        pendingInsertions.add(sym);
    }

    public static boolean lookup(String name){
        SymbolInfo sym = st.lookup(name);
        //System.out.println("Looking for the name: "+name);
        if(sym==null) return false;
        return true;
    }

    public static void addToSymbolTable(){
        //System.out.println("printing scopetable debug "+st.getAllScopesAsString());
        for(SymbolInfo item: pendingInsertions){
            st.insert(item);
        }
        //System.out.println("printing scopetable debug done"+st.getAllScopesAsString());
        pendingInsertions.clear();
    }
    public static void addToSymbolTable(String type){
        for(SymbolInfo item: pendingInsertions){
            //item.IDtype = type;
            boolean b = st.insert(item);
            if(b==true){
                System.out.println(item.getPrintingLine());
                item.setIDType(type);
            }
        }
        pendingInsertions.clear();
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java Main <input_file>");
            return;
        }

        File inputFile = new File(args[0]);
        if (!inputFile.exists()) {
            System.err.println("Error opening input file: " + args[0]);
            return;
        }

        String outputDirectory = "output/";
        String parserLogFileName = outputDirectory + "parserLog.txt";
        String errorFileName = outputDirectory + "errorLog.txt";
        String lexLogFileName = outputDirectory + "lexerLog.txt";
        pendingInsertions = new ArrayList<>();


        new File(outputDirectory).mkdirs();

        parserLogFile = new BufferedWriter(new FileWriter(parserLogFileName));
        errorFile = new BufferedWriter(new FileWriter(errorFileName));
        lexLogFile = new BufferedWriter(new FileWriter(lexLogFileName));

        // Create lexer and parser
        CharStream input = CharStreams.fromFileName(args[0]);
        C8086Lexer lexer = new C8086Lexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        C8086Parser parser = new C8086Parser(tokens);

        //Create SymbolTable
        st = new SymbolTable(7);

        // Remove default error listener
        parser.removeErrorListeners();

        // Begin parsing
        ParseTree tree = parser.start();
        // parserLogFile.write("Parse tree: " + tree.toStringTree(parser) + "\n");

        // Close files
        parserLogFile.close();
        errorFile.close();
        lexLogFile.close();

        System.out.println("Parsing completed. Check the output files for details.");
    }
}
