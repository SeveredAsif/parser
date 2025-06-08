public class SymbolTable {
    private ScopeTable currentScope;
    private int bucketCount;

    public SymbolTable(int bucketCount, ScopeTable.HashFunction hashFunc) {
        this.bucketCount = bucketCount;
        this.currentScope = new ScopeTable(bucketCount, null, hashFunc);
        System.out.println("\tScopeTable# " + currentScope.getId() + " created");
    }

    public SymbolTable(int bucketCount) {
        this(bucketCount, ScopeTable::sdbmHash);
    }

    public ScopeTable getCurrentScope() {
        return currentScope;
    }

    public void enterScope() {
        ScopeTable newScope = new ScopeTable(bucketCount, currentScope, ScopeTable::sdbmHash);
        currentScope = newScope;
        System.out.println("\tScopeTable# " + currentScope.getId() + " created");
    }

    public void exitScope() {
        if (currentScope != null && currentScope.getParent() != null) { // Avoid removing global scope
            System.out.println("\tScopeTable# " + currentScope.getId() + " removed");
            currentScope = currentScope.getParent();
        }
    }

    public boolean insert(String name, String type) {
        return currentScope.insert(name, type, "<" + name + "," + type + ">");
    }

    public boolean remove(String name) {
        return currentScope.delete(name);
    }

    public SymbolInfo lookup(String name) {
        ScopeTable temp = currentScope;
        while (temp != null) {
            SymbolInfo found = temp.lookup(name);
            if (found != null) {
                return found;
            }
            temp = temp.getParent();
        }
        System.out.println("\t'" + name + "' not found in any of the ScopeTables");
        return null;
    }

    public void printCurrentScope() {
        if (currentScope != null) {
            currentScope.print(1);
        }
    }

    public void printAllScopes() {
        ScopeTable temp = currentScope;
        int indent = 1;
        while (temp != null) {
            temp.print(indent);
            indent++;
            temp = temp.getParent();
        }
    }
}
