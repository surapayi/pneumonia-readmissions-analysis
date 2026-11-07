# Pneumonia Readmissions: Where Should Care Coordinators Follow Up First?

A business intelligence project using real hospital data. I look at which pneumonia patients are most likely to come back to the hospital within 30 days, based on where they went after discharge and how long they stayed.

**Status:** Phase 1 (Excel exploration) is done. Phase 2 (SQL) and Phase 3 (Power BI dashboard) are in progress.

---

## The question

> Among pneumonia patients, which combinations of discharge destination and length of stay have the highest 30-day readmission risk, and which segments should care coordinators follow up with first?

**Who this is for:** care coordinators and discharge planners, who decide which patients to call first after discharge.

## Key findings

1. **Where patients go after discharge matters.** Patients discharged to **home with a health service** (12.9%) or to **skilled nursing, rehab, or other facility care** (12.2%) were readmitted much more often than patients who went **home** (7.6%). The overall rate was 9.6%.
2. **Those two groups carry more than their share.** They are 39% of stays but 51% of readmissions (180 of 354).
3. **Longer stays had higher readmission rates overall.** The rate was 8.4% for 1-3 days, 9.1% for 4-6 days, and 11.7% for 7+ days. But this pattern comes mostly from patients who went home. For home-with-health-service patients, short stays had the highest rate (15.4%).
4. **One segment stands out.** Skilled nursing/rehab/facility patients with 7+ day stays (13.5%, 95% range 9.8% to 17.1%) are the only segment whose range sits entirely above the overall average. I treat it as the best place to start a pilot, not as a confirmed high-risk group, because the lower end is close to the average.
5. **The highest single rate is not proven.** Home with health service with 1-3 day stays has the highest rate (15.4%), but its range (9.2% to 21.6%) includes the average. I call it "worth watching."
6. **Home patients with short stays are the lowest priority.** Their rates (6.5% and 7.4%) are clearly below average.

## Recommendation

- Focus follow-up first on the two higher-risk groups: **home with health service** and **skilled nursing/rehab/facility**.
- Within those, start with **skilled nursing/rehab/facility patients with 7+ day stays**, and keep an eye on **home-with-health-service patients with short stays**.
- Run a small pilot, such as earlier follow-up calls for these groups, and track whether their readmission rates drop. This data can show where risk is concentrated. It cannot show which action works.
- "Other" destinations are too small and too mixed to interpret.

## Results

### By discharge destination

| Destination | Stays | Readmissions | Rate | 95% range | Extra vs. average* |
|---|---|---|---|---|---|
| Home | 2,150 | 164 | 7.6% | 6.5% to 8.7% | -42 |
| Home with health service | 550 | 71 | 12.9% | 10.1% to 15.7% | +18 |
| Skilled nursing/rehab/facility | 891 | 109 | 12.2% | 10.1% to 14.4% | +24 |
| Other | 108 | 10 | 9.3% | 3.8% to 14.7% | 0 |
| **All stays** | **3,699** | **354** | **9.6%** | 8.6% to 10.5% | |

### By destination and length of stay (LOS)

| Destination | LOS | Stays | Readmissions | Rate | 95% range | Extra vs. average* | vs. overall rate |
|---|---|---|---|---|---|---|---|
| Home | 1-3 days | 905 | 59 | 6.5% | 4.9% to 8.1% | -28 | Below |
| Home | 4-6 days | 812 | 60 | 7.4% | 5.6% to 9.2% | -18 | Below |
| Home | 7+ days | 433 | 45 | 10.4% | 7.5% to 13.3% | +4 | Not clear |
| Home with health service | 1-3 days | 130 | 20 | 15.4% | 9.2% to 21.6% | +8 | Not clear |
| Home with health service | 4-6 days | 222 | 28 | 12.6% | 8.2% to 17.0% | +7 | Not clear |
| Home with health service | 7+ days | 198 | 23 | 11.6% | 7.2% to 16.1% | +4 | Not clear |
| Skilled nursing/rehab/facility | 1-3 days | 179 | 23 | 12.8% | 7.9% to 17.8% | +6 | Not clear |
| Skilled nursing/rehab/facility | 4-6 days | 378 | 41 | 10.8% | 7.7% to 14.0% | +5 | Not clear |
| Skilled nursing/rehab/facility | 7+ days | 334 | 45 | 13.5% | 9.8% to 17.1% | +13 | Above |
| Other | All LOS | 108 | 10 | 9.3% | 3.8% to 14.7% | 0 | Not clear |

\* **Extra vs. average** = actual readmissions minus the readmissions expected if the segment had the overall rate (stays x 9.57%). A positive number means more readmissions than average.

**How to read "vs. overall rate":** "Above" or "Below" means the whole 95% range sits on one side of the overall rate (9.57%). "Not clear" means the range includes it.

## Data

- **Source:** [Diabetes 130-US Hospitals for Years 1999-2008](https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008), UCI Machine Learning Repository. It has more than 100,000 hospital stays from 130 US hospitals.
- **Original study:** Strack et al., "Impact of HbA1c Measurement on Hospital Readmission Rates," *BioMed Research International*, 2014.
- The raw data file is not included in this repo. Download it from the link above.
- **Planned:** CMS Hospital Readmissions Reduction Program (HRRP) pneumonia data, as a national benchmark only. It will not be joined to this dataset.

- **Dataset:** Clore, J., Cios, K., DeShazo, J., & Strack, B. (2014). *Diabetes 130-US Hospitals for Years 1999-2008* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5230J
- It has more than 100,000 hospital stays from 130 US hospitals.
- **Original study:** Strack et al., "Impact of HbA1c Measurement on Hospital Readmission Rates," *BioMed Research International*, 2014.
- The raw data file is not included in this repo. Download it from the link above.

## Definitions

| Term | How I defined it |
|---|---|
| Pneumonia stay | Primary diagnosis (`diag_1`) is an ICD-9 code from 480 to 486 |
| Readmission | `readmitted = "<30"` (back in the hospital within 30 days). `>30` and `NO` count as not readmitted |
| Unit of analysis | One hospital stay. A patient with several stays is counted several times |
| Destination groups | Home / Home with health service / Skilled nursing, rehab, or other facility care / Other. IDs are grouped with a mapping table (see the `Dest_Map` sheet) |
| LOS bands | 1-3, 4-6, and 7+ days, set near the 33rd and 67th percentiles of the stay distribution so each band holds a similar share of stays |

## Analysis population

- 3,982 stays had pneumonia as the primary diagnosis.
- I excluded **283 stays**: patients who died or went to hospice (not at risk of a typical 30-day readmission) and stays with an unknown discharge destination (can't be assigned to a group).
- This leaves **3,699 stays** with **354 readmissions** (9.6%). The exclusions removed 11 readmissions.

## Method (Phase 1: Excel)

1. Filtered the primary diagnosis to ICD-9 480-486.
2. Created a 0/1 readmission flag, so that the average equals the readmission rate.
3. Built a destination mapping table and grouped discharge IDs into categories.
4. Excluded expired, hospice, and unknown destinations.
5. Checked the length-of-stay distribution and the readmission rate for each day. Chose LOS bands.
6. Built pivot tables of stays, readmissions, and rates by destination and LOS band.
7. Calculated 95% margins of error: 1.96 x sqrt(p x (1 - p) / n).
8. Applied minimum-size rules: no interpretation under 30 stays, and a caution flag for 30 to 99 stays.
9. Compared each segment's range with the overall rate and calculated extra readmissions.

The full step-by-step action log, with the reasons for each step, is in the Excel file.

## Why I used margins of error

Each rate comes from a limited number of stays, so it could shift by chance. Small groups have wide margins. The margin helps me judge which gaps between groups are probably real and which could be noise. For example, home vs. home with health service is a likely real gap, but home with health service vs. skilled nursing is too close to separate.

## Limitations

- **Association, not cause.** Patients sent to a facility or given home health are often sicker to begin with. The destination may be a marker of that, not the reason for readmission.
- **Diabetes patients only.** The dataset covers stays by patients with diabetes, so pneumonia results may not apply to all pneumonia patients.
- **Old data.** The stays are from 1999 to 2008, and care practices have changed.
- **Stays, not patients.** Patients with several stays are counted more than once, so rows are not fully independent.
- **Margins cover random variation only.** They do not account for bias. They use a normal approximation, which is rough for small counts. The overall rate also includes the segment being compared, which makes the comparison slightly lenient.
- **Small segments.** Several destination-by-LOS segments have only 100 to 200 stays, so rankings between neighbors are not reliable.
- **No severity or age adjustment.** I did not control for age, number of prior visits, or other factors. This is a possible next step.

## Next steps

- [ ] **Phase 2, SQL:** load the data, rebuild the same tables with queries (JOINs, `CASE WHEN`, `GROUP BY`), and check the totals against the Excel results (3,699 stays, 354 readmissions).
- [ ] **Phase 3, Power BI:** build a dashboard with the destination-by-LOS matrix, flags for small segments, and a "follow up first" view.
- [ ] Add a small ICD-9 lookup table for the pneumonia code group.
- [ ] Add the CMS HRRP pneumonia benchmark for national context.
- [ ] Optional: check whether the destination gap holds after accounting for age and prior visits.

## Repo contents

```
├── README.md
├── excel/
│   └── pneumonia_readmission_analysis.xlsx   # data tab, Dest_Map, pivots, Results, action log
├── sql/                                      # coming in Phase 2
└── powerbi/                                  # coming in Phase 3
```

## Skills practiced

Defining a business question and KPIs, data cleaning, ICD code grouping, pivot tables, rates vs. counts, sample-size and margin-of-error checks, and writing findings and recommendations for a non-technical audience. SQL and Power BI are in progress.

## About

Created by Bam as a portfolio project for healthcare business analyst and business intelligence roles.
