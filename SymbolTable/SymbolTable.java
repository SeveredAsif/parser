package SymbolTable;

public class SymbolTable {
    private ScopeTable currentScope;
    private int bucketCount;

    public SymbolTable(int bucketCount, ScopeTable.HashFunction hashFunc) {
        this.bucketCount = bucketCount;
        this.currentScope = new ScopeTable(bucketCount, hashFunc);
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
        currentScope.numberOfChildren++;
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
        return currentScope.insert(name, type, "< " + name + " : " + type + " >");
    }

    public boolean insert(SymbolInfo s) {
        return currentScope.insert(s);
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

    public String printCurrentScope() {
        StringBuilder sb = new StringBuilder();
        sb.append(currentScope.getString(1));
        return sb.toString();
    }
    public String getAllScopesAsString() {
        ScopeTable temp = currentScope;
        int indent = 1;
        StringBuilder sb = new StringBuilder();
    
        while (temp != null) {
            sb.append(temp.getString(indent));  
            indent++;
            temp = temp.getParent();
        }
    
        return sb.toString();
    }
    
}
