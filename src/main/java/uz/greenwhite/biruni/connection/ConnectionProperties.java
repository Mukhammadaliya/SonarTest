package uz.greenwhite.biruni.connection;

public class ConnectionProperties {
    private final String url;
    private final String user;
    private final String password;
    private final int inactiveConnectionTimeout;
    private final int maxConnectionReuse;
    private final int maxConnectionReuseTime;
    private final int initialPoolSize;
    private final int minPoolSize;
    private final int maxPoolSize;

    public ConnectionProperties(String url,
                                String user,
                                String password,
                                String inactiveConnectionTimeout,
                                String maxConnectionReuse,
                                String maxConnectionReuseTime,
                                String initialPoolSize,
                                String minPoolSize,
                                String maxPoolSize) {
        this.url = url;
        this.user = user;
        this.password = password;
        this.inactiveConnectionTimeout = inactiveConnectionTimeout.isEmpty() ? 60 : Integer.parseInt(inactiveConnectionTimeout); // default 1 minute
        this.maxConnectionReuse = maxConnectionReuse.isEmpty() ? 1000 : Integer.parseInt(maxConnectionReuse); // default 1000
        this.maxConnectionReuseTime = maxConnectionReuseTime.isEmpty() ? 1800 : Integer.parseInt(maxConnectionReuseTime); // default 30 minutes
        this.initialPoolSize = initialPoolSize.isEmpty() ? 0 : Integer.parseInt(initialPoolSize); // default 0
        this.minPoolSize = minPoolSize.isEmpty() ? 0 : Integer.parseInt(minPoolSize); // default 0
        this.maxPoolSize = maxPoolSize.isEmpty() ? Integer.MAX_VALUE : Integer.parseInt(maxPoolSize); // default unlimited
    }

    protected String getUrl() {
        return url;
    }

    protected String getUser() {
        return user;
    }

    protected String getPassword() {
        return password;
    }

    protected int getInactiveConnectionTimeout() {
        return inactiveConnectionTimeout;
    }

    protected int getMaxConnectionReuse() {
        return maxConnectionReuse;
    }

    protected int getMaxConnectionReuseTime() {
        return maxConnectionReuseTime;
    }

    protected int getInitialPoolSize() {
        return initialPoolSize;
    }

    protected int getMinPoolSize() {
        return minPoolSize;
    }

    protected int getMaxPoolSize() {
        return maxPoolSize;
    }
}
