# Workflow Tool Sequences

Exact MCP tool call sequences for each financial advisor workflow. Tool names are as registered by the Monarch Money MCP server (without the `mcp__monarchmoney__` prefix — that is added automatically).

When a specific module tool is unavailable, fall back to core tools: `get_accounts`, `get_transactions`, `get_budgets`.

---

## Workflow 1: Financial Health Check

### Phase 1 — Parallel Scan
```
PARALLEL:
  insights_getQuickStats {}
  get_accounts { verbosity: "light" }
  cashflow_getCashflowSummary {}
  budget_getVarianceSummary {}
  spending_getByCategoryMonth { topN: 10 }
  recurring_getRecurringStreams {}
```

### Phase 2 — Conditional Drill-Down (Sequential)
```
IF savings_rate < 0.20:
  cashflow_getCashflowByCategory {}

IF any_account_balance < 0:
  accounts_getById { id: <negative_account_id> }

IF max_budget_variance > 0.15:
  budgets_getBudgetVariance {}
```

### Phase 3 — Compute
Load `references/financial-ratios-benchmarks.md`. Calculate health score using weighted formula.

### Fallback (Core Tools Only)
```
PARALLEL:
  get_accounts { verbosity: "light" }
  get_transactions { limit: 100, verbosity: "light" }
  get_budgets { verbosity: "light" }
```
Derive savings rate, DTI, and other metrics from raw data.

---

## Workflow 2: Monthly Review

### Phase 1 — Parallel
```
PARALLEL:
  insights_getMonthlyComparison {}
  cashflow_getCashflowByMonth { months: 2 }
  budget_getVarianceSummary {}
  insights_getUnusualSpending {}
  insights_getTopMerchants {}
  insights_getIncomeVsExpenses {}
```

### Quarterly Extension — Additional Parallel
```
PARALLEL:
  insights_getNetWorthHistory { months: 6 }
  insights_getSpendingTrends {}
  insights_getIncomeTrends {}
  cashflow_getAverageCashflow {}
```

### Fallback
```
get_transactions { limit: 200, startDate: "first-of-last-month", endDate: "today", verbosity: "standard" }
```
Manually compute month-over-month comparisons from transaction data.

---

## Workflow 3: Budget Optimization

### Phase 1 — Parallel
```
PARALLEL:
  budgets_getBudgets { verbosity: "standard" }
  budgets_getBudgetVariance {}
  spending_getByCategoryMonth { topN: 20 }
  cashflow_getCashflowByCategory {}
  categories_getCategories {}
```

### Phase 2 — Sequential (if needed)
```
spending_getByCategoryMonth { month: "YYYY-MM (prev month)" }
spending_getByCategoryMonth { month: "YYYY-MM (2 months ago)" }
```

### Fallback
```
PARALLEL:
  get_budgets { verbosity: "standard" }
  get_transactions { limit: 200, verbosity: "light" }
```
Manually categorize and compute variances.

---

## Workflow 4: Spending Analysis

### Phase 1 — Parallel
```
PARALLEL:
  insights_getSpendingByCategory { months: 3 }
  insights_getSpendingTrends {}
  insights_getUnusualSpending {}
  insights_getTopMerchants {}
  transactions_smartQuery { query: "largest transactions this month" }
```

### Fallback
```
get_transactions { limit: 300, startDate: "3-months-ago", verbosity: "standard" }
```
Manually aggregate by category and merchant.

---

## Workflow 5: Net Worth Tracking

### Phase 1 — Parallel
```
PARALLEL:
  insights_getNetWorthHistory { months: 12 }
  get_accounts { verbosity: "standard" }
  accounts_getBalanceTrends { period: "month" }
  accounts_getHoldings {}
```

### Fallback
```
get_accounts { verbosity: "standard" }
```
Net worth = sum of asset accounts - sum of liability accounts. No history available in fallback mode.

---

## Workflow 6: Cash Flow Optimization

### Phase 1 — Parallel
```
PARALLEL:
  cashflow_getCashflowSummary {}
  cashflow_getIncomeStreams {}
  cashflow_getExpenseStreams {}
  cashflow_getCashflowByMonth { months: 6 }
  cashflow_getAverageCashflow {}
  cashflow_forecastCashflow {}
  recurring_getRecurringStreams {}
```

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "light" }
  get_transactions { limit: 300, startDate: "6-months-ago", verbosity: "light" }
```
Manually compute income vs expenses by month.

---

## Workflow 7: Debt Payoff

### Phase 1 — Parallel
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  recurring_getRecurringStreams {}
  cashflow_getCashflowSummary {}
```

### Phase 2 — Sequential
```
transactions_smartQuery { query: "interest charges" }
transactions_smartQuery { query: "finance charge" }
```

### Phase 3 — Compute
Load `references/debt-management-strategies.md`.
Filter accounts to liabilities only. Ask user for interest rates. Run avalanche and snowball calculations.

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  get_transactions { limit: 100, verbosity: "light" }
```
Filter to liability accounts and identify recurring payments.

---

## Workflow 8: Emergency Fund

### Phase 1 — Parallel
```
PARALLEL:
  get_accounts { verbosity: "light" }
  cashflow_getAverageCashflow {}
  cashflow_getExpenseStreams {}
  recurring_getRecurringStreams {}
```

### Compute
Filter accounts to liquid types (checking, savings, money market). Sum balances. Calculate essential expenses from expense streams and recurring items.

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  get_transactions { limit: 200, verbosity: "light" }
```
Identify liquid accounts by type. Calculate average monthly expenses from transactions.

---

## Workflow 9: Portfolio Review

### Phase 1 — Parallel
```
PARALLEL:
  accounts_getHoldings {}
  get_accounts { verbosity: "standard" }
  accounts_getBalanceHistory {}
  insights_getNetWorthHistory {}
```

### Phase 2 — Detail (if needed)
```
accounts_getHoldingDetails { holdingId: <concentrated_holding_id> }
```

### Compute
Load `references/investment-allocation-frameworks.md`.
Classify holdings by asset class (from names/tickers). Calculate allocation percentages. Compare to age-based targets.

### Fallback
```
get_accounts { verbosity: "standard" }
```
Investment accounts identified by type. Holdings detail unavailable — note limitation.

---

## Workflow 10: Retirement Readiness

### Phase 1 — Parallel
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  accounts_getHoldings {}
  insights_getNetWorthHistory { months: 24 }
  cashflow_getAverageCashflow {}
  cashflow_getIncomeStreams {}
```

### Phase 2 — User Input
Ask for: age, target retirement age, expected Social Security (optional).

### Compute
Load `references/financial-ratios-benchmarks.md`.
Filter to retirement accounts. Project growth at 7% nominal (4% real). Apply 4% rule. Compare to Fidelity milestones.

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  get_transactions { limit: 100, verbosity: "light" }
```
Identify retirement accounts by type. Estimate savings rate from transactions.

---

## Workflow 11: Tax Optimization

### Phase 1 — Parallel
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  categories_getCategorySpending {}
  cashflow_getIncomeStreams {}
  accounts_getHoldings {}
```

### Phase 2 — Sequential Searches
```
transactions_smartQuery { query: "charitable donation" }
transactions_smartQuery { query: "medical dental doctor" }
transactions_smartQuery { query: "education tuition" }
```

### Compute
Load `references/tax-planning-strategies.md`.
Identify tax-advantaged accounts and utilization. Sum deductible categories. Compare to standard deduction.

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "standard" }
  get_transactions { limit: 300, verbosity: "standard" }
```
Search transactions for deductible keywords manually.

---

## Workflow 12: Subscription Audit

### Phase 1 — Parallel
```
PARALLEL:
  recurring_getRecurringStreams {}
  recurring_getRecurringByCategory {}
  transactions_smartQuery { query: "subscription monthly" }
  insights_getTopMerchants {}
```

### Compute
Deduplicate recurring items. Classify as essential vs discretionary. Calculate totals and % of income.

### Fallback
```
get_transactions { limit: 300, startDate: "3-months-ago", verbosity: "standard" }
```
Identify recurring patterns by merchant frequency and consistent amounts.

---

## Workflow 13: Savings Rate

### Phase 1 — Parallel
```
PARALLEL:
  cashflow_getCashflowSummary {}
  cashflow_getCashflowByMonth { months: 12 }
  cashflow_getAverageCashflow {}
  cashflow_getIncomeStreams {}
  insights_getIncomeVsExpenses {}
```

### Compute
Calculate monthly savings rate = (income - expenses) / income for each month. Compute 3/6/12-month averages. Determine trend.

### Fallback
```
get_transactions { limit: 500, startDate: "12-months-ago", verbosity: "light" }
```
Manually separate income and expense transactions by month.

---

## Workflow 14: Financial Goals

### Phase 1 — User Input
Prompt for: goal name, target amount, target date, current savings toward goal.

### Phase 2 — Parallel
```
PARALLEL:
  cashflow_getAverageCashflow {}
  get_accounts { verbosity: "light" }
  cashflow_forecastCashflow {}
```

### Compute
Calculate required monthly savings. Compare to available surplus. Project scenarios.

### Fallback
```
PARALLEL:
  get_accounts { verbosity: "light" }
  get_transactions { limit: 100, verbosity: "light" }
```
Estimate available surplus from recent transaction history.
