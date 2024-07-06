package uz.greenwhite.biruni.connection;

import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;
import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;

import java.sql.SQLException;

public class DBConnection {
    private static DBConnection instance;

    private final PoolDataSource poolDataSource;
    private final OracleDataSource oracleDataSource;

    private DBConnection(ConnectionProperties properties) throws SQLException {
        poolDataSource = PoolDataSourceFactory.getPoolDataSource();

        poolDataSource.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
        poolDataSource.setURL(properties.getUrl());
        poolDataSource.setUser(properties.getUser());
        poolDataSource.setPassword(properties.getPassword());
        poolDataSource.setInactiveConnectionTimeout(properties.getInactiveConnectionTimeout());
        poolDataSource.setMaxConnectionReuseCount(properties.getMaxConnectionReuse());
        poolDataSource.setInitialPoolSize(properties.getInitialPoolSize());
        poolDataSource.setMaxConnectionReuseTime(properties.getMaxConnectionReuseTime());
        poolDataSource.setMinPoolSize(properties.getMinPoolSize());
        poolDataSource.setMaxPoolSize(properties.getMaxPoolSize());

        oracleDataSource = new OracleDataSource();

        oracleDataSource.setURL(properties.getUrl());
        oracleDataSource.setUser(properties.getUser());
        oracleDataSource.setPassword(properties.getPassword());
    }

    public static synchronized void Init(ConnectionProperties properties) throws SQLException {
        if (instance == null) {
            instance = new DBConnection(properties);
        }
    }

    private static void checkInitialization() {
        if (instance == null) throw new RuntimeException("Database connection is not initialized");
    }

    public static void freeAllResources(OracleConnection connection) throws SQLException {
        String query = "BEGIN Dbms_Session.Modify_Package_State(Dbms_Session.Free_All_Resources); commit; END;";

        try(OracleCallableStatement statement = (OracleCallableStatement) connection.prepareCall(query)) {
            statement.execute();
        }
    }

    public static OracleConnection getPoolConnection() throws SQLException {
        checkInitialization();
        return (OracleConnection) instance.poolDataSource.getConnection();
    }

    public static OracleConnection getPoolConnectionAndFreeResources() throws SQLException {
        OracleConnection connection = getPoolConnection();
        freeAllResources(connection);
        return connection;
    }

    public static OracleConnection getSingletonConnection() throws SQLException {
        checkInitialization();
        return (OracleConnection) instance.oracleDataSource.getConnection();
    }
}
