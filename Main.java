public class Main {
    public static void main(String[] args) {
        // Create a symbol table with 7 buckets
        SymbolTable table = new SymbolTable(7);

        // Insert symbols into global scope
        table.insert("x", "int");
        table.insert("y", "float");

        // Print current scope (should show x and y)
        table.printCurrentScope();

        // Lookup existing symbol
        SymbolInfo found = table.lookup("x");
        System.out.println(found != null ? "Found: " + found.getName() + ", " + found.getType() : "Not found");

        // Lookup non-existing symbol
        SymbolInfo notFound = table.lookup("z");
        System.out.println(notFound != null ? "Found: " + notFound.getName() : "Not found");

        // Enter a new scope
        table.enterScope();

        // Insert new symbol in inner scope
        table.insert("z", "char");

        // Shadow variable 'x' in inner scope
        table.insert("x", "double");

        // Print current scope
        table.printCurrentScope();

        // Lookup 'x' (should find double in inner scope)
        SymbolInfo shadowedX = table.lookup("x");
        System.out.println("Shadowed x: " + shadowedX.getName() + ", " + shadowedX.getType());

        // Print all scopes
        table.printAllScopes();

        // Exit inner scope
        table.exitScope();

        // Print current scope after popping
        table.printCurrentScope();

        // Try deleting a symbol
        boolean deleted = table.remove("x");
        System.out.println(deleted ? "'x' deleted successfully." : "Failed to delete 'x'.");

        // Print current scope again
        table.printCurrentScope();
    }
}
