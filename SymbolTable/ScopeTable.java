package SymbolTable;

public class ScopeTable {
    //private static int scopeIdCounter = 1;
    private int id;
    private SymbolInfo[] table;
    private int numBuckets;
    private ScopeTable parentScope;
    private int collisionCount;
    private HashFunction hashFunc;
    public int numberOfChildren;

    public interface HashFunction {
        int hash(String str, int numBuckets);
    }

    // Constructor
    public ScopeTable(int size, ScopeTable parent, HashFunction hashFunc) {
        this.id = parent.numberOfChildren+1;
        this.numBuckets = size;
        this.table = new SymbolInfo[size];
        this.parentScope = parent;
        this.collisionCount = 0;
        this.numberOfChildren = 0;
        this.hashFunc = hashFunc != null ? hashFunc : ScopeTable::sdbmHash;
    }

    public ScopeTable(int size, HashFunction hashFunc) {
        this.id = 1;
        this.numBuckets = size;
        this.table = new SymbolInfo[size];
        this.parentScope = null;
        this.collisionCount = 0;
        this.numberOfChildren = 0;
        this.hashFunc = hashFunc != null ? hashFunc : ScopeTable::sdbmHash;
    }

    // Default constructor with SDBMHash
    public ScopeTable(int size) {
        this.id = 1;
        this.numBuckets = size;
        this.table = new SymbolInfo[size];
        this.parentScope = null;
        this.collisionCount = 0;
        this.numberOfChildren = 0;
        this.hashFunc = hashFunc != null ? hashFunc : ScopeTable::sdbmHash;
    }

    public ScopeTable getParent() {
        return parentScope;
    }

    public int getId() {
        return id;
    }

    public int getCollisionCount() {
        return collisionCount;
    }

    public boolean insert(String name, String type, String printingLine) {
        int chainPos = 1;
        SymbolInfo newSymbol = new SymbolInfo(name, type, printingLine);
        int bucket = hashFunc.hash(name, numBuckets);

        SymbolInfo head = table[bucket];
        if (head == null) {
            table[bucket] = newSymbol;
            System.out.printf("\tInserted in ScopeTable# %d at position %d, %d\n", id, bucket + 1, chainPos);
            return true;
        } else {
            collisionCount++;
            SymbolInfo temp = head;
            if (temp.getName().equals(name)) {
                System.out.printf("\t'%s' already exists in the current ScopeTable\n", name);
                return false;
            }
            while (temp.getNext() != null) {
                temp = temp.getNext();
                chainPos++;
                if (temp.getName().equals(name)) {
                    System.out.printf("\t'%s' already exists in the current ScopeTable\n", name);
                    return false;
                }
            }
            temp.setNext(newSymbol);
            chainPos++;
            System.out.printf("\tInserted in ScopeTable# %d at position %d, %d\n", id, bucket + 1, chainPos);
            return true;
        }
    }

    public boolean insert(SymbolInfo newSymbol) {
        int chainPos = 1;
        //SymbolInfo newSymbol = new SymbolInfo(name, type, printingLine);
        int bucket = hashFunc.hash(newSymbol.getName(), numBuckets);

        SymbolInfo head = table[bucket];
        if (head == null) {
            table[bucket] = newSymbol;
            System.out.printf("\tInserted in ScopeTable# %d at position %d, %d\n", id, bucket + 1, chainPos);
            return true;
        } else {
            collisionCount++;
            SymbolInfo temp = head;
            if (temp.getName().equals(newSymbol.getName())) {
                System.out.printf("\t'%s' already exists in the current ScopeTable\n", newSymbol.getName());
                return false;
            }
            while (temp.getNext() != null) {
                temp = temp.getNext();
                chainPos++;
                if (temp.getName().equals(newSymbol.getName())) {
                    System.out.printf("\t'%s' already exists in the current ScopeTable\n", newSymbol.getName());
                    return false;
                }
            }
            temp.setNext(newSymbol);
            chainPos++;
            System.out.printf("\tInserted in ScopeTable# %d at position %d, %d\n", id, bucket + 1, chainPos);
            return true;
        }
    }


    public SymbolInfo lookup(String name) {
        int bucket = hashFunc.hash(name, numBuckets);
        SymbolInfo temp = table[bucket];
        int chainPos = 1;

        while (temp != null) {
            if (temp.getName().equals(name)) {
                System.out.printf("\t'%s' found in ScopeTable# %d at position %d, %d\n", name, id, bucket + 1, chainPos);
                return temp;
            }
            temp = temp.getNext();
            chainPos++;
        }
        return null;
    }

    public boolean delete(String name) {
        int bucket = hashFunc.hash(name, numBuckets);
        int chainPos = 1;
        SymbolInfo temp = table[bucket];

        if (temp == null) return false;

        if (temp.getName().equals(name)) {
            table[bucket] = temp.getNext();
            System.out.printf("\tDeleted '%s' from ScopeTable# %d at position %d, %d\n", name, id, bucket + 1, chainPos);
            return true;
        }

        while (temp.getNext() != null) {
            if (temp.getNext().getName().equals(name)) {
                SymbolInfo toDelete = temp.getNext();
                temp.setNext(toDelete.getNext());
                System.out.printf("\tDeleted '%s' from ScopeTable# %d at position %d, %d\n", name, id, bucket + 1, chainPos);
                return true;
            }
            temp = temp.getNext();
            chainPos++;
        }

        return false;
    }
    public String getFullId() {
        if (getParent() == null) return String.valueOf(id);  // Root scope
        return getParent().getFullId() + "." + id;
    }

    public String getString(int indentLevel) {
        StringBuilder sb = new StringBuilder();
        // String indent = "\t".repeat(indentLevel);
        //StringBuilder count =new StringBuilder();
        // count.append("1");

        // if(id>1){
        //     count.append(".");
        //     count.append(String.valueOf(id-1));
        // }    
        sb.append("ScopeTable # ").append(getFullId()).append("\n");
    
        for (int i = 0; i < numBuckets; i++) {
            SymbolInfo current = table[i];
            if (current != null) {
                sb.append(i).append(" --> ");
                while (current != null) {
                    sb.append(current.getPrintingLine()).append("");
                    current = current.getNext();
                }
                sb.append("\n");
            }
        }
    
        return sb.toString();
    }
    

    

    public static int sdbmHash(String str, int numBuckets) {
        long hash = 0;
        for (char c : str.toCharArray()) {
            hash = (c + (hash << 6) + (hash << 16) - hash);
            hash &= 0xFFFFFFFFL; // simulate 32-bit unsigned overflow
        }
        return (int)(hash % numBuckets);
    }
    

    public static int djb2Hash(String str, int numBuckets) {
        long hash = 5381;
        for (char c : str.toCharArray()) {
            hash = ((hash << 5) + hash) + c; 
        }
        return (int) (hash % numBuckets);
    }

    public static int polynomialHash(String str, int numBuckets) {
        int p = 31;
        long m = (long) 1e9 + 9;
        long hash = 0, p_pow = 1;
        for (char c : str.toCharArray()) {
            hash = (hash + (c - 'a' + 1) * p_pow) % m;
            p_pow = (p_pow * p) % m;
        }
        return (int) (hash % numBuckets);
    }
}
