// RethinkDB initialization script for development environment
r = require('rethinkdb');

// Configuration
const config = {
    host: 'localhost',
    port: 28015,
    password: process.env.RETHINKDB_PASSWORD || '',
    user: process.env.RETHINKDB_USERNAME || 'admin'
};

// Development database name
const devDbName = process.env.DEV_DB_NAME || 'development';
const createTestDb = process.env.CREATE_TEST_DB === 'true';

// Utility function to create a database and tables
async function createDatabase(conn, dbName) {
    console.log(`Creating database '${dbName}'...`);
    
    try {
        // Create database if it doesn't exist
        await r.dbList().contains(dbName)
            .do(exists => r.branch(
                exists,
                { created: 0 },
                r.dbCreate(dbName)
            )).run(conn);

        // Create development tables
        const tables = [
            { name: 'users', indexes: ['email', 'username'] },
            { name: 'posts', indexes: ['author_id', 'created_at'] },
            { name: 'comments', indexes: ['post_id', 'author_id', 'created_at'] },
            { name: 'tags', indexes: ['name'] },
            { name: 'categories', indexes: ['name', 'parent_id'] }
        ];

        for (const table of tables) {
            // Create table if it doesn't exist
            await r.db(dbName).tableList().contains(table.name)
                .do(exists => r.branch(
                    exists,
                    { created: 0 },
                    r.db(dbName).tableCreate(table.name, {
                        primaryKey: 'id',
                        durability: 'soft'  // Development setting
                    })
                )).run(conn);

            // Create indexes
            for (const index of table.indexes) {
                await r.db(dbName).table(table.name).indexList()
                    .contains(index)
                    .do(exists => r.branch(
                        exists,
                        { created: 0 },
                        r.db(dbName).table(table.name).indexCreate(index)
                    )).run(conn);
            }

            // Wait for indexes
            await r.db(dbName).table(table.name).indexWait().run(conn);
        }

        console.log(`Database '${dbName}' setup completed`);
    } catch (err) {
        console.error(`Error setting up database '${dbName}':`, err);
        throw err;
    }
}

// Create development monitoring functions
async function createMonitoringFunctions(conn) {
    console.log('Creating monitoring functions...');
    
    try {
        await r.db('rethinkdb').table('current_issues')
            .changes()
            .run(conn, function(err, cursor) {
                if (err) throw err;
                cursor.each(function(err, change) {
                    if (err) throw err;
                    console.log('System issue:', change);
                });
            });

        // Create monitoring tables
        const monitoringDb = 'dev_monitoring';
        await r.dbList().contains(monitoringDb)
            .do(exists => r.branch(
                exists,
                { created: 0 },
                r.dbCreate(monitoringDb)
            )).run(conn);

        // Create monitoring tables
        const monitoringTables = [
            'query_stats',
            'table_stats',
            'server_stats',
            'job_logs'
        ];

        for (const table of monitoringTables) {
            await r.db(monitoringDb).tableList().contains(table)
                .do(exists => r.branch(
                    exists,
                    { created: 0 },
                    r.db(monitoringDb).tableCreate(table)
                )).run(conn);
        }

        // Set up periodic stats collection
        setInterval(async () => {
            try {
                // Collect server stats
                const stats = await r.db('rethinkdb').table('stats').run(conn);
                await r.db(monitoringDb).table('server_stats').insert({
                    timestamp: r.now(),
                    stats: stats
                }).run(conn);

                // Collect query stats
                const queries = await r.db('rethinkdb').table('jobs').run(conn);
                await r.db(monitoringDb).table('query_stats').insert({
                    timestamp: r.now(),
                    queries: queries
                }).run(conn);
            } catch (err) {
                console.error('Error collecting stats:', err);
            }
        }, 5000); // Every 5 seconds

        console.log('Monitoring setup completed');
    } catch (err) {
        console.error('Error setting up monitoring:', err);
        throw err;
    }
}

// Main initialization function
async function initialize() {
    let conn;
    
    try {
        // Connect to RethinkDB
        console.log('Connecting to RethinkDB...');
        conn = await r.connect(config);

        // Create development database
        await createDatabase(conn, devDbName);

        // Create test database if enabled
        if (createTestDb) {
            await createDatabase(conn, 'test');
        }

        // Set up monitoring
        await createMonitoringFunctions(conn);

        // Create development user if specified
        if (process.env.DEV_DB_USER && process.env.DEV_DB_PASSWORD) {
            console.log('Creating development user...');
            await r.db('rethinkdb').table('users').insert({
                id: process.env.DEV_DB_USER,
                password: process.env.DEV_DB_PASSWORD
            }, { conflict: 'update' }).run(conn);
        }

        console.log('Development environment initialization completed successfully');
    } catch (err) {
        console.error('Initialization error:', err);
        process.exit(1);
    } finally {
        if (conn) {
            conn.close();
        }
    }
}

// Run initialization
initialize();
