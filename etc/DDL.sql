--
-- Product
--
CREATE TABLE IF NOT EXISTS t_product
(
  pr_site VARCHAR(16) NOT NULL,
  pr_code VARCHAR(32) NOT NULL,
  pr_inst VARCHAR(32) NOT NULL,
  pr_fund VARCHAR(32) NOT NULL,
  pr_disp VARCHAR(16) NOT NULL,
  pr_expr TIMESTAMP
);

DROP INDEX IF EXISTS t_product_0;

ALTER TABLE t_product
  ADD CONSTRAINT t_product_0
PRIMARY KEY
  (
    pr_site,
    pr_code
  );

--
-- Evaluation
--
CREATE TABLE IF NOT EXISTS t_evaluation
(
  ev_site         VARCHAR(16) NOT NULL,
  ev_unit         VARCHAR(32) NOT NULL,
  ev_ticker_site  VARCHAR(16),
  ev_ticker_code  VARCHAR(32),
  ev_convert_site VARCHAR(16),
  ev_convert_code VARCHAR(32)
);

DROP INDEX IF EXISTS t_evaluation_0;

ALTER TABLE t_evaluation
  ADD CONSTRAINT t_evaluation_0
PRIMARY KEY
  (
    ev_site,
    ev_unit
  );

--
-- Account
--
CREATE TABLE IF NOT EXISTS t_account
(
  ac_site VARCHAR(16) NOT NULL,
  ac_acct VARCHAR(16) NOT NULL,
  ac_unit VARCHAR(16) NOT NULL,
  ac_disp VARCHAR(16) NOT NULL
);

DROP INDEX IF EXISTS i_account_0;

ALTER TABLE t_account
  ADD CONSTRAINT i_account_0
PRIMARY KEY
  (
    ac_site,
    ac_acct,
    ac_unit
  );

--
-- Ticker
--
CREATE TABLE IF NOT EXISTS t_ticker
(
  tk_site VARCHAR(16) NOT NULL,
  tk_code VARCHAR(32) NOT NULL,
  tk_time TIMESTAMP   NOT NULL,
  tk_ask  DECIMAL(32, 16),
  tk_bid  DECIMAL(32, 16),
  tk_ltp  DECIMAL(32, 16)
);

DROP INDEX IF EXISTS i_ticker_0;

ALTER TABLE t_ticker
  ADD CONSTRAINT i_ticker_0
PRIMARY KEY
  (
    tk_site,
    tk_code,
    tk_time
  );

DROP INDEX IF EXISTS i_ticker_1;

CREATE INDEX i_ticker_1
  ON t_ticker
  (
    tk_time,
    tk_site,
    tk_code
  );

--
-- Balance
--
CREATE TABLE IF NOT EXISTS t_balance
(
  bc_site VARCHAR(16) NOT NULL,
  bc_acct VARCHAR(16) NOT NULL,
  bc_unit VARCHAR(16) NOT NULL,
  bc_time TIMESTAMP   NOT NULL,
  bc_amnt DECIMAL(32, 16)
);

DROP INDEX IF EXISTS i_balance_0;

ALTER TABLE t_balance
  ADD CONSTRAINT i_balance_0
PRIMARY KEY
  (
    bc_site,
    bc_acct,
    bc_unit,
    bc_time
  );

DROP INDEX IF EXISTS i_balance_1;

CREATE INDEX i_balance_1
  ON t_balance
  (
    bc_time,
    bc_site,
    bc_acct,
    bc_unit
  );

--
-- Position
--
CREATE TABLE IF NOT EXISTS t_position
(
  ps_site VARCHAR(16) NOT NULL,
  ps_code VARCHAR(32) NOT NULL,
  ps_time TIMESTAMP   NOT NULL,
  ps_inst DECIMAL(32, 16),
  ps_fund DECIMAL(32, 16)
);

DROP INDEX IF EXISTS i_position_0;

ALTER TABLE t_position
  ADD CONSTRAINT i_position_0
PRIMARY KEY
  (
    ps_site,
    ps_code,
    ps_time
  );

DROP INDEX IF EXISTS i_position_1;

CREATE INDEX i_position_1
  ON t_position
  (
    ps_time,
    ps_site,
    ps_code
  );

--
-- Transaction
--
CREATE TABLE IF NOT EXISTS t_transaction
(
  tx_site VARCHAR(16) NOT NULL,
  tx_code VARCHAR(32) NOT NULL,
  tx_type VARCHAR(16) NOT NULL,
  tx_acct VARCHAR(16) NOT NULL,
  tx_oid  VARCHAR(64) NOT NULL,
  tx_eid  VARCHAR(64) NOT NULL,
  tx_time TIMESTAMP   NOT NULL,
  tx_inst DECIMAL(32, 16),
  tx_fund DECIMAL(32, 16)
);

DROP INDEX IF EXISTS i_transaction_0;

ALTER TABLE t_transaction
  ADD CONSTRAINT i_transaction_0
PRIMARY KEY
  (
    tx_site,
    tx_code,
    tx_type,
    tx_acct,
    tx_oid,
    tx_eid
  );

DROP INDEX IF EXISTS i_transaction_1;

CREATE INDEX i_transaction_1
  ON t_transaction
  (
    tx_time,
    tx_site,
    tx_code,
    tx_type,
    tx_acct
  );

--
-- Metric
--
-- [Grafana]
-- SELECT mc_time as time, mc_name as metric, sum(mc_amnt) FROM t_metric
--   WHERE mc_type = 'test' AND $__timeFilter(mc_time)
--   GROUP BY mc_time, mc_name
--   ORDER BY mc_time, mc_name
--
-- [Actual]
-- SELECT mc_time as time, mc_name as metric, sum(mc_amnt) as value FROM t_metric
--   WHERE mc_type = 'test' AND extract(epoch from mc_time)
--     BETWEEN extract(epoch from now() - INTERVAL '1 day') AND extract(epoch from now())
--   GROUP BY mc_time, mc_name
--   ORDER BY mc_time, mc_name
--
CREATE TABLE IF NOT EXISTS t_metric
(
  mc_type VARCHAR(32) NOT NULL,
  mc_time TIMESTAMP   NOT NULL,
  mc_name VARCHAR(32) NOT NULL,
  mc_amnt DECIMAL(32, 16)
);

DROP INDEX IF EXISTS i_metric_0;

ALTER TABLE t_metric
  ADD CONSTRAINT i_metric_0
PRIMARY KEY
  (
    mc_type,
    mc_time,
    mc_name
  );

DROP INDEX IF EXISTS i_metric_1;

CREATE INDEX i_metric_1
  ON t_metric
  (
    mc_type,
    extract(EPOCH FROM mc_time),
    mc_name
  );

CREATE INDEX i_metric_2
  ON t_metric
  (
    mc_time
  );


--
-- Mock for Grafana's built-in function
--
CREATE OR REPLACE FUNCTION "$__timeFilter"(TIMESTAMP)
  RETURNS BOOLEAN
AS $$
SELECT extract(EPOCH FROM $1) >= extract(EPOCH FROM t.now - INTERVAL '1 day')
       AND
       extract(EPOCH FROM $1) < extract(EPOCH FROM t.now)
FROM (SELECT now() AS now) AS t
$$
RETURNS NULL ON NULL
INPUT
LANGUAGE SQL;
