package de.saumya.jibernate;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import org.hibernate.jdbc.Work;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UpdateWork implements Work {

    private final Logger logger = LoggerFactory.getLogger(Work.class);

    private final String sql;

    public UpdateWork(final String sql) {
        this.sql = sql;
    }

    public void execute(final Connection con) throws SQLException {
        final Statement statement = con.createStatement();
        try {
            statement.executeUpdate(this.sql);
        }
        finally {
            try {
                statement.close();
            }
            catch (final Exception e) {
                this.logger.warn("error closing the statement for " + this.sql,
                                 e);
            }
        }
    }
}
