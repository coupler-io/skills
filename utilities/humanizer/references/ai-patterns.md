# AI writing patterns: full catalog

Source: Wikipedia's "Signs of AI writing" page, maintained by WikiProject AI Cleanup. Enhanced with additional patterns observed in LLM output post-2023.

---

## Content patterns

### 1. Undue emphasis on significance, legacy, and broader trends

**Words to watch:** stands/serves as, is a testament/reminder, a vital/significant/crucial/pivotal/key/dramatic role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted

**Problem:** LLM writing inflates importance by claiming arbitrary aspects represent or contribute to a broader topic.

Before:
> The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance.

After:
> The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office.

### 2. Undue emphasis on notability and media coverage

**Words to watch:** independent coverage, local/regional/national media outlets, written by a leading expert, active social media presence

**Problem:** Lists sources without context, asserting notability rather than demonstrating it.

Before:
> Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu. She maintains an active social media presence with over 500,000 followers.

After:
> In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods.

### 3. Superficial analyses with -ing endings

**Words to watch:** highlighting/underscoring/emphasizing..., ensuring..., reflecting/symbolizing..., contributing to..., cultivating/fostering..., encompassing..., showcasing...

**Problem:** Participial ("-ing") phrases tacked onto sentences to fake analytical depth.

Before:
> The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes, reflecting the community's deep connection to the land.

After:
> The temple uses blue, green, and gold colors. The architect said these were chosen to reference local bluebonnets and the Gulf coast.

### 4. Promotional and advertisement-like language

**Words to watch:** boasts a, vibrant, rich (figurative), profound, enhancing its, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking (figurative), renowned, breathtaking, must-visit, stunning

**Problem:** Neutral tone collapses into tourism-brochure copy, especially on cultural or geographic topics.

Before:
> Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and stunning natural beauty.

After:
> Alamata Raya Kobo is a town in the Gonder region of Ethiopia, known for its weekly market and 18th-century church.

### 5. Vague attributions and weasel words

**Words to watch:** Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few cited)

**Problem:** Opinions attributed to unnamed authorities. No specific source, no credibility.

Before:
> Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Experts believe it plays a crucial role in the regional ecosystem.

After:
> The Haolai River supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences.

### 6. Outline-like "challenges and future prospects" sections

**Words to watch:** Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook

**Problem:** Formulaic sections that acknowledge problems only to immediately dismiss them with optimism.

Before:
> Despite its industrial prosperity, Korattur faces challenges typical of urban areas, including traffic congestion and water scarcity. Despite these challenges, with its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of Chennai's growth.

After:
> Traffic congestion increased after 2015 when three new IT parks opened. The municipal corporation began a stormwater drainage project in 2022 to address recurring floods.

---

## Language and grammar patterns

### 7. Overused "AI vocabulary" words

**High-frequency AI words:** Additionally, align with, commendable, crucial, delve, emphasizing, enduring, enhance, foster/fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), multifaceted, notably, pivotal, realm, resonate, showcase, synergy, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant

**Problem:** These words appear at vastly higher frequency in post-2023 LLM text than in human writing. They often cluster together.

Before:
> Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta in the local culinary landscape, showcasing how these dishes have integrated into the traditional diet.

After:
> Somali cuisine also includes camel meat, which is considered a delicacy. Pasta dishes, introduced during Italian colonization, remain common, especially in the south.

### 8. Copula avoidance ("is"/"are" replacement)

**Words to watch:** serves as/stands as/marks/represents [a], boasts/features/offers [a]

**Problem:** Simple "is" or "has" replaced with elaborate constructions that add no meaning.

Before:
> Gallery 825 serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces and boasts over 3,000 square feet.

After:
> Gallery 825 is LAAA's exhibition space for contemporary art. The gallery has four rooms totaling 3,000 square feet.

### 9. Negative parallelisms

**Pattern:** "Not only...but...", "It's not just about..., it's...", "It's not merely..., it's..."

**Problem:** Overused rhetorical construction that signals LLM output.

Before:
> It's not just about the beat riding under the vocals; it's part of the aggression and atmosphere. It's not merely a song, it's a statement.

After:
> The heavy beat adds to the aggressive tone.

### 10. Rule of three overuse

**Problem:** Ideas forced into groups of three to appear comprehensive or rhythmic.

Before:
> The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights.

After:
> The event includes talks and panels. There's also time for informal networking between sessions.

### 11. Elegant variation (synonym cycling)

**Problem:** Repetition-penalty behavior causes excessive synonym substitution for the same referent.

Before:
> The protagonist faces many challenges. The main character must overcome obstacles. The central figure eventually triumphs. The hero returns home.

After:
> The protagonist faces many challenges but eventually triumphs and returns home.

### 12. False ranges

**Problem:** "From X to Y" constructions where X and Y aren't on a meaningful scale.

Before:
> Our journey through the universe has taken us from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter.

After:
> The book covers the Big Bang, star formation, and current theories about dark matter.

---

## Style patterns

### 13. Em dash overuse

**Problem:** Em dashes (—) used more frequently than human writers would. Mimics punchy sales or editorial writing.

**Rule of thumb:** More than one em dash per paragraph warrants scrutiny. Replace most with commas, periods, or parentheses.

Before:
> The term is primarily promoted by Dutch institutions—not by the people themselves. You don't say "Netherlands, Europe" as an address—yet this mislabeling continues—even in official documents.

After:
> The term is primarily promoted by Dutch institutions, not by the people themselves. You don't say "Netherlands, Europe" as an address, yet this mislabeling continues in official documents.

### 14. Overuse of boldface

**Problem:** Mechanical emphasis on terms and acronyms, especially on first mention.

Before:
> It blends **OKRs** (Objectives and Key Results), **KPIs** (Key Performance Indicators), and visual strategy tools such as the **Business Model Canvas** (BMC) and **Balanced Scorecard** (BSC).

After:
> It blends OKRs, KPIs, and visual strategy tools like the Business Model Canvas and Balanced Scorecard.

### 15. Inline-header vertical lists

**Problem:** Lists where each item starts with a bolded header followed by a colon and a sentence. Reads like an outline, not prose.

Before:
> * **User Experience:** The user experience has been significantly improved with a new interface.
> * **Performance:** Performance has been enhanced through optimized algorithms.
> * **Security:** Security has been strengthened with end-to-end encryption.

After:
> The update improves the interface, speeds up load times through optimized algorithms, and adds end-to-end encryption.

### 16. Title Case in headings

**Problem:** Capitalizing all main words in headings. Human web writing overwhelmingly uses sentence case.

Before:
> Strategic Negotiations And Global Partnerships

After:
> Strategic negotiations and global partnerships

### 17. Decorative emojis

**Problem:** Emojis used as bullet decorators or heading ornaments.

Before:
> 🚀 Launch Phase: The product launches in Q3 💡 Key Insight: Users prefer simplicity ✅ Next Steps: Schedule follow-up meeting

After:
> The product launches in Q3. User research showed a preference for simplicity. Next step: schedule a follow-up meeting.

---

## Communication artifacts

### 18. Collaborative communication residue

**Words to watch:** I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., let me know, here is a...

**Problem:** Chatbot conversational scaffolding pasted into content. Not part of the actual writing.

Before:
> Here is an overview of the French Revolution. I hope this helps! Let me know if you'd like me to expand on any section.

After:
> The French Revolution began in 1789 when financial crisis and food shortages led to widespread unrest.

### 19. Knowledge-cutoff disclaimers

**Words to watch:** as of [date], Up to my last training update, While specific details are limited/scarce..., based on available information...

**Problem:** AI disclaimers about incomplete information accidentally left in the output.

Before:
> While specific details about the company's founding are not extensively documented in readily available sources, it appears to have been established sometime in the 1990s.

After:
> The company was founded in 1994, according to its registration documents.

### 20. Sycophantic/servile tone

**Problem:** Overly positive, people-pleasing language that no human editor would use.

Before:
> Great question! You're absolutely right that this is a complex topic. That's an excellent point about the economic factors.

After:
> The economic factors you mentioned are relevant here.

---

## Filler and hedging

### 21. Filler phrases

Replace mechanically:

| AI filler | Human version |
|-----------|--------------|
| In order to achieve this goal | To achieve this |
| Due to the fact that | Because |
| At this point in time | Now |
| In the event that | If |
| has the ability to | can |
| It is important to note that | (delete — just state the thing) |
| It is worth mentioning that | (delete) |
| It should be noted that | (delete) |
| In terms of | (delete or rephrase) |
| When it comes to | (delete or rephrase) |

### 22. Excessive hedging

**Problem:** Over-qualifying statements with stacked modals and qualifiers.

Before:
> It could potentially possibly be argued that the policy might have some effect on outcomes.

After:
> The policy may affect outcomes.

### 23. Generic positive conclusions

**Problem:** Vague upbeat endings that say nothing specific.

Before:
> The future looks bright for the company. Exciting times lie ahead as they continue their journey toward excellence. This represents a major step in the right direction.

After:
> The company plans to open two more locations next year.

---

## Full example

Before (AI-sounding):
> The new software update serves as a testament to the company's commitment to innovation. Moreover, it provides a seamless, intuitive, and powerful user experience — ensuring that users can accomplish their goals efficiently. It's not just an update, it's a revolution in how we think about productivity. Industry experts believe this will have a lasting impact on the entire sector, highlighting the company's pivotal role in the evolving technological landscape.

After (humanized):
> The software update adds batch processing, keyboard shortcuts, and offline mode. Early feedback from beta testers has been positive, with most reporting faster task completion.

Changes:
- Removed "serves as a testament" (pattern 1: inflated significance)
- Removed "Moreover" (pattern 7: AI vocabulary)
- Removed "seamless, intuitive, and powerful" (pattern 10: rule of three + pattern 4: promotional)
- Removed em dash + "ensuring" phrase (pattern 3: superficial -ing analysis)
- Removed "It's not just...it's..." (pattern 9: negative parallelism)
- Removed "Industry experts believe" (pattern 5: vague attribution)
- Removed "pivotal role" and "evolving landscape" (pattern 7: AI vocabulary)
- Added specific features and concrete feedback
