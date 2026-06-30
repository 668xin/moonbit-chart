# Chart Demo

## Monthly Sales

This is a **grouped bar chart** showing sales data for two products over six months.

@chart: bar
title: Monthly Sales
width: 600
height: 400
categories: Jan, Feb, Mar, Apr, May, Jun
dataset: Product A, #4E79A7, 120, 200, 150, 80, 230, 180
dataset: Product B, #F28E2B, 90, 140, 200, 160, 120, 210
@end

## Revenue Trends

A *multi-line chart* comparing revenue and cost over four quarters.

@chart: line
title: Revenue Trends
width: 600
height: 400
categories: Q1, Q2, Q3, Q4
dataset: Revenue, #4E79A7, 300, 450, 380, 520
dataset: Cost, #F28E2B, 200, 280, 250, 310
@end

## Market Share

A pie chart showing market share distribution. See [MoonBit](https://moonbitlang.com) for details.

@chart: pie
title: Market Share
width: 500
height: 400
dataset: Product A, #4E79A7, 35
dataset: Product B, #F28E2B, 25
dataset: Product C, #E15759, 20
dataset: Product D, #76B7B2, 15
dataset: Others, #B07AA1, 5
@end

## Performance Review

A radar chart comparing two teams across five dimensions.

@chart: radar
title: Performance Review
width: 500
height: 500
categories: Speed, Quality, Cost, Service, Innovation
dataset: Team A, #4E79A7, 90, 80, 70, 85, 75
dataset: Team B, #F28E2B, 75, 85, 90, 70, 80
@end

## Stacked Expenses

A stacked bar chart showing expense breakdown by category.

@chart: bar
title: Stacked Expenses
width: 600
height: 400
theme: light
stacked: true
categories: Rent, Food, Transport, Entertainment
dataset: Alice, #4E79A7, 800, 400, 150, 200
dataset: Bob, #F28E2B, 800, 500, 200, 100
dataset: Carol, #E15759, 800, 300, 100, 300
@end

---

## Dark Theme Examples

### Weekly Activity (Dark)

@chart: bar
title: Weekly Activity
width: 600
height: 400
theme: dark
categories: Mon, Tue, Wed, Thu, Fri, Sat, Sun
dataset: Active Users, #4E79A7, 1200, 1500, 1300, 1800, 1600, 900, 700
@end

### Browser Share (Dark)

@chart: pie
title: Browser Share
width: 480
height: 420
theme: dark
dataset: Chrome, #4E79A7, 65
dataset: Safari, #F28E2B, 19
dataset: Firefox, #E15759, 8
dataset: Edge, #76B7B2, 5
dataset: Other, #B07AA1, 3
@end

---

## Boundary Cases

### Annual Profit (With Negatives)

@chart: bar
title: Annual Profit by Quarter
width: 500
height: 350
categories: Q1, Q2, Q3, Q4
dataset: Net Profit, #E15759, 45, -15, 60, -5
@end

### Annual Sales (12 Months)

@chart: bar
title: Annual Sales Trend
width: 700
height: 380
categories: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
dataset: Sales, #4E79A7, 45, 60, 80, 55, 90, 110, 130, 95, 70, 85, 100, 120
@end
