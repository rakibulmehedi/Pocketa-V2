# Helm — Google Play Store Launch & Marketing Design

**Date:** 2026-06-23
**Author:** Chief Architect (Rakibul Islam Mehedi)
**Status:** Approved — awaiting implementation plan

---

## 1. Objective

Release Helm v1.0.0 on the Google Play Store as a **free app** for Bangladeshi USD-earning freelancers, then execute a **৳5,000–৳20,000 paid Facebook/Instagram campaign** alongside an organic community launch. Paid tier (Pro ৳299/month) ships in a fast-follow update after launch validation.

**Timeline:** 8–12 weeks from 2026-06-23.
**Target:** 500+ installs in first 30 days, ≥4.2 Play Store rating, ≥40% Day-7 retention.

---

## 2. Approach: Sequential Gates (Doctrine-Aligned)

Approach A was selected: each phase must clear its gate before the next begins. This protects Play Store credibility — a finance app's first 50 reviews are permanent.

```
P1: Security → P2: QA → P3: Closed Beta → P4: Store Listing → P5: Launch + Marketing
```

---

## 3. Phase Definitions

### Phase 1 — Security Completion (Weeks 1–3)

**Goal:** Close all remaining S1 security findings before any public exposure.

**Current state:**
- 97 total findings from adversarial audit
- ~29 still pending (after S1-W4 and S1-W5)
- 2 BLOCKER QA findings: API 21 manifest override + font bundling

**Work:**
- Fix BLOCKER 1: `android/app/build.gradle.kts` → `minSdk = 21` + `tools:overrideLibrary` in AndroidManifest
- Fix BLOCKER 2: Bundle Inter, JetBrains Mono, Hind Siliguri as `.ttf` assets; remove `google_fonts` dependency
- Complete remaining critical/high S1 findings (per `docs/planning/QA_FIX_DISPATCH.md` and `docs/planning/TDD_DISPATCH_SPRINT_S1_SECURITY_HARDENING.md`)
- Add security regression tests for every fixed finding

**Gate to proceed:**
- `dart analyze` 0/0/0
- All 17 CRITICAL + 35 HIGH findings resolved
- ≤10 LOW findings remaining
- Re-audit clean
- All tests pass

**Agents:**
| Agent | File | Role |
|-------|------|------|
| `security-reviewer` | `security-reviewer.md` | Audit remaining findings, assign wave order |
| `security-appsec-engineer` | `security-appsec-engineer.md` | Fix auth/input/crypto/storage findings |
| `flutter-reviewer` | `flutter-reviewer.md` | Review all security-touched Flutter files |
| `tdd-guide` | `tdd-guide.md` | Write regression tests per finding |
| `build-error-resolver` | `build-error-resolver.md` | Fix 2 BLOCKER build issues |

**Parallelism:** security-appsec-engineer + tdd-guide run in parallel per wave. flutter-reviewer runs after each wave completes.

---

### Phase 2 — QA Re-Run & Hardening (Week 4)

**Goal:** Confirm all 9 QA findings from 2026-06-15 are resolved. Produce a "GO" verdict.

**Work:**
- Run 10-gate QA script (`docs/beta/MANUAL_QA_SCRIPT.md`) on physical reference device (Galaxy A14, API 33)
- Capture screenshot evidence for every gate
- Fix any regressions surfaced
- Confirm release APK signs with release keystore (human step: provide keystore)
- Build `.aab` (Android App Bundle) for Play Store submission
- Verify `targetSdk = 35`, `minSdk = 21`, `versionName = 1.0.0`, `versionCode = 1`

**Gate to proceed:**
- All 10 QA gates: PASS
- AAB builds successfully with release keystore
- APK size ≤25MB
- No BLOCKER or HIGH findings

**Agents:**
| Agent | File | Role |
|-------|------|------|
| `testing-evidence-collector` | `testing-evidence-collector.md` | Screenshot-based 10-gate QA execution |
| `testing-reality-checker` | `testing-reality-checker.md` | Production readiness GO/NO-GO verdict |
| `e2e-runner` | `e2e-runner.md` | Automated E2E critical flows |
| `flutter-reviewer` | `flutter-reviewer.md` | Final code review before release |

---

### Phase 3 — Closed Beta on Play Internal Testing Track (Weeks 5–7)

**Goal:** Validate the 5 doctrine thresholds with 15–25 real Bangladeshi freelancers before public listing.

**Work:**
- Create Play Console account (human: $25 registration)
- Upload AAB to Internal Testing track
- Recruit 15–25 beta testers from Onyx Traders Telegram + freelancer Facebook groups
- Run 4-week beta per `docs/strategy/BETA_VALIDATION_PROTOCOL.md`
- Collect weekly feedback using `docs/beta/FOUNDER_OBSERVATION_SHEET.md`
- Synthesize findings weekly → fix critical UX issues

**Doctrine thresholds (all 5 must pass; 2+ misses = KILL):**
| Threshold | Target |
|-----------|--------|
| Pipeline compliance | ≥85% of users add ≥1 income entry |
| Override-equivalent behavior | <5% |
| Day-28 retention | ≥60% |
| Onboarding completion | ≥70% |
| S2S comprehension | ≥80% (verified via founder conversation) |

**Gate to proceed:**
- All 5 thresholds met
- No KILL signal
- Critical UX issues resolved

**Agents:**
| Agent | File | Role |
|-------|------|------|
| `marketing-app-store-optimizer` | `marketing-app-store-optimizer.md` | Internal Testing track setup + tester recruitment copy |
| `marketing-growth-hacker` | `marketing-growth-hacker.md` | Qualifying pain post for Onyx Traders + beta recruitment |
| `product-feedback-synthesizer` | `product-feedback-synthesizer.md` | Weekly beta feedback synthesis |
| `product-manager` | `product-manager.md` | Go/No-Go decision against 5 thresholds |

---

### Phase 4 — Play Store Listing & ASO (Week 8)

**Goal:** Build a complete, optimized Play Store listing in English and Bangla before production publish.

**Deliverables:**
- App title: "Helm — Freelancer Cashflow" (max 30 chars)
- Short description (80 chars): "আসল খরচযোগ্য টাকা জানো মুহূর্তেই — USD freelancer-দের জন্য"
- Full description (4,000 chars): EN + BN versions
- Release notes (500 chars)
- 8× phone screenshots (EN + BN)
- 1× feature graphic (1024×500px)
- Privacy policy URL (live page required by Play Store)
- Content rating questionnaire completed (Finance category)
- App category: Finance
- Target countries: Bangladesh (primary), India (secondary)

**ASO keyword targets (Bangla + English mix):**
- "freelancer payment tracker bangladesh"
- "payoneer bdt calculator"
- "safe to spend freelancer"
- "ফ্রিল্যান্সার টাকা ট্র্যাকার"
- "USD to BDT cashflow"

**Agents (run in parallel):**
| Agent | File | Role |
|-------|------|------|
| `marketing-app-store-optimizer` | `marketing-app-store-optimizer.md` | Keyword research, title/subtitle, metadata |
| `marketing-content-creator` | `marketing-content-creator.md` | Full description (EN + BN), release notes |
| `design-ui-designer` | `design-ui-designer.md` | Screenshots, feature graphic |
| `engineering-technical-writer` | `engineering-technical-writer.md` | Privacy policy page |

**Gate to proceed:**
- All store listing assets complete
- Privacy policy URL live
- Play Console listing saved (not yet published)

---

### Phase 5 — Production Launch + Marketing (Weeks 9–12)

**Goal:** Public launch on Play Store + organic community drop + ৳5–20K paid Facebook/Instagram campaign.

#### 5A — Technical Launch (Week 9)
- Bump `versionCode` if needed, publish AAB to Production track
- Monitor Play Console for crashes (Android vitals)
- Respond to first reviews within 24 hours

#### 5B — Organic Launch Sequence (Week 9)

| Day | Action | Channel |
|-----|--------|---------|
| D-7 | Qualifying pain question — no product mention | Onyx Traders Telegram (50K) |
| D-3 | Founder story in Bangla: "আমি কেন Helm বানালাম" | 3 freelancer Facebook groups |
| D-1 | Teaser screenshot: S2S hero card with BDT number | LinkedIn + personal Facebook |
| D0 | Full launch post with Play Store link | All channels |
| D+3 | Reply thread — answer every comment personally | All channels |
| D+7 | "First week" transparency post | LinkedIn |

**Cadence (Weeks 9–12):**
- 2× Bangla posts/week in freelancer Facebook groups
- 1× founder update/week on LinkedIn
- Weekly reply to every Telegram mention

#### 5C — Paid Campaign (Weeks 10–12)

**Total budget: ৳5,000–৳20,000**

| Campaign | Budget | Audience | Duration |
|----------|--------|----------|----------|
| Test | ৳3,000 | BD freelancers, Payoneer/Fiverr/Upwork interest, 22–35 | Week 10 (7 days) |
| Scale winner | ৳12,000 | Lookalike from install data + best test audience | Weeks 11–12 |

**3 ad creative variants (A/B/C test in Week 10):**
- **Variant A (Pain hook):** "পেমেন্ট ক্লিয়ার হয়নি, কিন্তু খরচ করে ফেললাম। Helm দিয়ে এটা আর হবে না।"
- **Variant B (Product reveal):** App screenshot showing exact spendable BDT number. "এটাই তোমার আসল খরচযোগ্য টাকা।"
- **Variant C (Social proof):** Beta tester quote in Bangla + star rating visual

**CTA:** "Free download" → Play Store link
**Target CPI:** ≤৳40 per install
**Scale trigger:** If CPI ≤৳40 and Day-3 retention ≥30% → scale with remaining budget

**Agents:**
| Agent | File | Role |
|-------|------|------|
| `marketing-growth-hacker` | `marketing-growth-hacker.md` | Full launch sequencing + community drop |
| `paid-media-creative-strategist` | `paid-media-creative-strategist.md` | 3 Facebook/Instagram ad creative variants |
| `paid-media-paid-social-strategist` | `paid-media-paid-social-strategist.md` | Campaign structure, audience targeting, budget pacing |
| `marketing-social-media-strategist` | `marketing-social-media-strategist.md` | Organic: Facebook groups, Telegram, LinkedIn |
| `marketing-pr-communications-manager` | `marketing-pr-communications-manager.md` | Community admin outreach, press |

---

## 4. Technical Release Requirements

### App Configuration
| Item | Required Value |
|------|---------------|
| `applicationId` | `com.safetospends.helm` |
| `versionName` | `1.0.0` |
| `versionCode` | `1` |
| `minSdkVersion` | `21` |
| `targetSdkVersion` | `35` |
| Build type | Release, minified, signed |
| Output format | `.aab` (Android App Bundle) |
| APK size target | ≤25MB |

### Human-Only Steps (cannot be automated)
1. Generate release keystore (`keytool` command)
2. Create Google Play Console account ($25 one-time fee)
3. Publish privacy policy to a live URL
4. Fill content rating questionnaire in Play Console
5. Final AAB upload + production track submit in Play Console

### Build Commands (executed by agents)
```bash
# Fix BLOCKER 1 (API 21)
# Edit android/app/build.gradle.kts: minSdk = 21
# Edit android/app/src/main/AndroidManifest.xml: add tools:overrideLibrary

# Fix BLOCKER 2 (fonts)
mkdir -p assets/fonts
# Download Inter, JetBrains Mono, Hind Siliguri .ttf files
# Update pubspec.yaml flutter.fonts section
# Replace all GoogleFonts.* calls in helm_typography.dart + app_theme.dart

# Release build
fvm flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Verify
aapt dump badging build/app/outputs/bundle/release/app-release.aab | grep sdkVersion
```

---

## 5. Success Metrics

| Metric | Target | Measured At |
|--------|--------|-------------|
| Play Store installs | 500+ | Day 30 |
| Day-7 retention | ≥40% | Day 7 |
| Day-28 retention | ≥25% | Day 28 |
| Play Store rating | ≥4.2 stars | Day 30 |
| Organic vs paid install split | ≥60% organic | Day 30 |
| Pipeline entry rate | ≥70% of installs | Day 7 |
| Facebook ad CPI | ≤৳40 | Week 10 test |
| Reviews responded to | 100% within 24h | Ongoing |

---

## 6. Timeline Summary

| Week | Phase | Key Deliverable |
|------|-------|----------------|
| 1 | P1 | 2 BLOCKERs fixed, S1 wave 1–3 complete |
| 2 | P1 | S1 waves 4–6 complete |
| 3 | P1 | Re-audit clean, ≤10 LOW remaining |
| 4 | P2 | QA re-run GO verdict, AAB signed |
| 5–6 | P3 | Beta live on Internal Track, 15–25 testers |
| 7 | P3 | Beta data synthesized, UX fixes shipped |
| 8 | P4 | Store listing complete, all assets ready |
| 9 | P5 | Production publish + organic community launch |
| 10 | P5 | Paid test campaign (৳3,000, 3 variants) |
| 11–12 | P5 | Scale winning variant (৳12,000) |

---

## 7. Constraints & Risks

| Risk | Mitigation |
|------|-----------|
| Beta thresholds not met (KILL signal) | Follow doctrine — do not publish. Fix and re-beta. |
| Play Store review rejection | Pre-check against Play Policy before submit. Privacy policy live. |
| Keystore loss | Store keystore + passwords in password manager + offline backup. Loss = cannot update app. |
| Facebook ad account restriction | Start with small spend. Use personal account, not new business account. |
| CPI > ৳40 | Kill paid campaign. Invest more in organic. Revisit paid after organic validation. |
| Google Fonts removal breaks UI | Bundle all 3 font families before removing dependency. Test on device before release. |

---

## 8. Out of Scope

- Paid tier (Pro ৳299/month) — fast-follow update, not v1.0.0
- iOS App Store release — deferred
- Cloud sync / backend — deferred per Doctrine §14
- Multi-wallet — Phase 5 (gated on beta thresholds)
- Invoice-Lite — Phase 6

---

## 9. References

- `docs/strategy/HELM_FINAL_PRODUCT_DOCTRINE.md` — strategic authority
- `docs/core/HELM_BRAIN.md` — product identity
- `docs/planning/QA_FIX_DISPATCH.md` — 9 QA findings to fix
- `docs/planning/TDD_DISPATCH_SPRINT_S1_SECURITY_HARDENING.md` — security waves
- `docs/beta/BETA_VALIDATION_PROTOCOL.md` — closed beta protocol
- `docs/beta/MANUAL_QA_SCRIPT.md` — 10-gate QA script
- `.commandcode/adversarial_audit_report.md` — 97 security findings
