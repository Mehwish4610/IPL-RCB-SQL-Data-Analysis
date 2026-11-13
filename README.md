
# 🏏 IPL RCB SQL Data Analysis | 2013–2016

### Turning Cricket Data into Strategic Insights Using SQL

An end-to-end SQL-based analytical case study examining the performance of **Royal Challengers Bengaluru (RCB)** across four IPL seasons (2013–2016), with a focus on player performance, team consistency, venue analysis, and strategic squad selection.

**Tools:** MySQL | MySQL Workbench | Excel | PowerPoint  
**Domain:** Sports Analytics | Data Analytics  
**Author:** Mehwish

---

## 📌 Project Overview

This project analyzes historical IPL match and ball-by-ball data to understand RCB's strengths, weaknesses, and opportunities for improvement.

The case study is framed around a hypothetical 2017 player auction, where the objective is to recommend effective player-selection strategies using historical performance data.

This is an independent educational project, not an official engagement with RCB.

## 🎯 Business Objectives

- Analyze RCB's performance across the 2013–2016 IPL seasons.
- Identify consistent batsmen, bowlers, and all-rounders.
- Evaluate season-wise batting and bowling performance.
- Examine venue-wise wins and losses.
- Study the influence of toss decisions and match conditions.
- Develop data-driven recommendations for team composition and player selection.

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| MySQL | Querying and analyzing IPL data |
| MySQL Workbench | Database exploration and SQL development |
| Excel | Charts and analytical summaries |
| PowerPoint | Presenting findings and recommendations |

### SQL Skills Demonstrated

- Joins and relational database querying
- Aggregate functions and grouping
- Subqueries and Common Table Expressions (CTEs)
- Window functions, including `LAG()`
- Conditional aggregation using `CASE`
- Filtering using `WHERE` and `HAVING`
- Date functions and performance calculations
- KPI development and analytical reporting


## 🔍 Key Analytical Questions

The project contains 15 objective analysis sections and 11 strategic discussion sections.

### Team Performance
- How did RCB's win percentage change across seasons?
- How did batting and bowling performance evolve?
- Did RCB improve compared with previous seasons?

### Player Performance
- Which batsmen recorded the highest strike rates?
- Which players consistently scored runs?
- Which bowlers delivered strong wicket-taking performances?
- Which players contributed in both batting and bowling?

### Match and Venue Analysis
- How did RCB perform across different venues?
- What was the relationship between toss decisions and match results?
- Which match conditions influenced team performance?

### Strategic Analysis
- What factors should influence player selection?
- How should RCB balance batting and bowling strengths?
- How can historical performance inform squad planning?

## 📊 Key Findings

### 1. RCB Win Percentage by Season

| Season | Win Percentage |
|--------|---------------:|
| 2013 | 56.25% |
| 2014 | 35.71% |
| 2015 | 50.00% |
| 2016 | 56.25% |

**Insight:** RCB experienced a significant decline in 2014 before recovering in 2015 and 2016. This highlighted inconsistency across seasons.

### 2. Batting Performance

RCB scored **2,977 runs in 2016**, the highest seasonal total within the analyzed period.

**Insight:** The team demonstrated strong batting capability, making retention of a reliable batting core an important strategic consideration.

### 3. Bowling Performance

| Season | Wickets Taken |
|--------|--------------:|
| 2014 | 67 |
| 2015 | 92 |
| 2016 | 89 |

**Insight:** Wicket-taking improved considerably in 2015 but declined slightly in 2016. Bowling balance and consistency deserve closer examination.

*These figures are reported in the project presentation and have not been independently revalidated through fresh query execution.*

## 💡 Strategic Recommendations

Based on the historical analysis:

1. **Retain a strong batting core:** Prioritize reliable and consistently performing batsmen.
2. **Strengthen bowling balance:** Evaluate bowlers using wicket-taking ability alongside other performance measures.
3. **Prioritize all-rounders:** Consider players who contribute meaningfully with both bat and ball.
4. **Use venue-specific insights:** Account for historical ground performance and match conditions.
5. **Evaluate consistency:** Consider performance across multiple matches and seasons rather than isolated standout performances.

These recommendations are based on the 2013–2016 dataset and are intended for the project's hypothetical 2017 auction scenario.

## ⚙️ How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Obtain the original IPL dataset from a source you are permitted to use.
3. Create or import the `ipl` database using the appropriate schema.
4. Open `sql/rcb_ipl_analysis.sql` in MySQL Workbench.
5. Execute the SQL queries section by section.
6. Review the outputs and compare them with the project presentation.

**Note:** The original dataset import script contains a `DROP DATABASE` command. Review it carefully before executing. The raw dataset is not included in this public-ready repository until redistribution permissions are verified.

## 📈 Project Deliverables

- SQL analysis covering team, player, and match performance
- Database model created in MySQL Workbench
- Analytical KPIs and performance comparisons
- Presentation of key findings and strategic recommendations

## ⚠️ Limitations

- The analysis covers historical IPL seasons from 2013 to 2016.
- Reported results have not been independently rerun during repository preparation.
- Actual auction-value optimization would require verified player-price data.
- Recommendations should not be treated as current IPL squad advice.

## 👩‍💻 About the Author

**Mehwish**

Computer Science Engineering graduate pursuing opportunities in Data Analytics and Data Science, with hands-on experience in SQL, Excel, data exploration, and analytical problem-solving.

**GitHub:** [Mehwish4610](https://github.com/Mehwish4610)

---

⭐ If you found this project interesting, feel free to explore the SQL queries and analysis presentation.
