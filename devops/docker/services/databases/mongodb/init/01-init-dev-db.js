// MongoDB initialization script for development environment

// Function to create a database and user
function createDbAndUser(dbName, username, password, roles = ['readWrite']) {
    db = db.getSiblingDB(dbName);
    
    // Create user if it doesn't exist
    try {
        db.createUser({
            user: username,
            pwd: password,
            roles: roles.map(role => ({ role: role, db: dbName }))
        });
        print(`Created user '${username}' for database '${dbName}'`);
    } catch (error) {
        if (!error.message.includes('already exists')) {
            throw error;
        }
        print(`User '${username}' already exists for database '${dbName}'`);
    }
    
    // Create some development collections
    db.createCollection('system_logs');
    db.createCollection('development_data');
    
    return db;
}

// Function to create development utility functions
function createUtilityFunctions(db) {
    // Create a function to show collection sizes
    db.system.js.save({
        _id: 'showCollectionSizes',
        value: function() {
            return db.getCollectionNames().map(function(name) {
                const stats = db.getCollection(name).stats();
                return {
                    collection: name,
                    size: Math.round(stats.size / 1024 / 1024 * 100) / 100 + ' MB',
                    storageSize: Math.round(stats.storageSize / 1024 / 1024 * 100) / 100 + ' MB',
                    indexes: stats.nindexes,
                    indexSize: Math.round(stats.totalIndexSize / 1024 / 1024 * 100) / 100 + ' MB'
                };
            });
        }
    });

    // Create a function to show slow queries
    db.system.js.save({
        _id: 'showSlowQueries',
        value: function(threshold = 100) {
            return db.system.profile.find({
                millis: { $gt: threshold }
            }).sort({ millis: -1 }).toArray();
        }
    });

    // Create a function to analyze indexes
    db.system.js.save({
        _id: 'analyzeIndexes',
        value: function() {
            return db.getCollectionNames().map(function(name) {
                const collection = db.getCollection(name);
                const indexes = collection.getIndexes();
                const stats = collection.stats();
                return {
                    collection: name,
                    documentCount: stats.count,
                    indexes: indexes.map(function(idx) {
                        return {
                            name: idx.name,
                            keys: Object.keys(idx.key),
                            size: Math.round(
                                stats.indexSizes[idx.name] / 1024 / 1024 * 100
                            ) / 100 + ' MB'
                        };
                    })
                };
            });
        }
    });

    // Create a function to show current operations
    db.system.js.save({
        _id: 'showOperations',
        value: function(includeIdle = false) {
            const ops = db.currentOp(includeIdle);
            return ops.inprog.map(function(op) {
                return {
                    opid: op.opid,
                    operation: op.op,
                    namespace: op.ns,
                    description: op.desc,
                    timeRunning: op.secs_running,
                    planSummary: op.planSummary
                };
            });
        }
    });

    print('Created utility functions: showCollectionSizes, showSlowQueries, analyzeIndexes, showOperations');
}

// Function to set up development settings
function setupDevSettings(db) {
    // Enable profiling for slow queries
    db.setProfilingLevel(1, { slowms: 100 });
    
    // Create indexes for system collections
    db.system_logs.createIndex({ timestamp: 1 });
    db.system_logs.createIndex({ level: 1 });
    db.system_logs.createIndex({ source: 1 });
    
    // Create a capped collection for logs
    db.createCollection('dev_logs', { 
        capped: true, 
        size: 100000000  // 100MB
    });
    
    print('Development settings configured');
}

// Main initialization
try {
    // Create admin user if not exists
    db = db.getSiblingDB('admin');
    if (!db.getUser('admin')) {
        db.createUser({
            user: 'admin',
            pwd: process.env.MONGO_INITDB_ROOT_PASSWORD,
            roles: ['root']
        });
        print('Created admin user');
    }

    // Development database setup
    const devDbName = process.env.DEV_DB_NAME || 'development';
    const devDbUser = process.env.DEV_DB_USER || 'developer';
    const devDbPassword = process.env.DEV_DB_PASSWORD || 'developer_password';
    
    const devDb = createDbAndUser(devDbName, devDbUser, devDbPassword, ['readWrite', 'dbAdmin']);
    createUtilityFunctions(devDb);
    setupDevSettings(devDb);

    // Test database setup if enabled
    if (process.env.CREATE_TEST_DB === 'true') {
        const testDb = createDbAndUser('test', 'tester', 'test_password', ['readWrite', 'dbAdmin']);
        setupDevSettings(testDb);
        print('Test database configured');
    }

    print('MongoDB initialization completed successfully');
} catch (error) {
    print('Error during initialization:');
    printjson(error);
    throw error;
}
