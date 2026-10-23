# Hock Kee catalogue research

Checked 23 October 2026. Research-stage project. No supply agreement, distribution authorisation, stock, EU sale price, export approval or launch date is implied. Database seeds create 15 real references and nine demand categories. They never seed subscribers, votes, prices or stock.

## Sources and how they were used

- [Manufacturer homepage](https://www.hockkeegroup.com/): identifies Hock Kee Kopitiam and its Malaysian/Nanyang positioning. Its footer identifies HOCK KEE F&B HOLDING SDN BHD; this is not enough to identify the legal manufacturer of each packaged SKU.
- [Official shop](https://www.hockkeegroup.com/shop-now/): the current shop is client-rendered. Its own JavaScript links to the following unauthenticated, public catalogue endpoints. No authentication, private routes or purchase requests were used.
- [Public product list used by the official shop](https://server.hockkeekopitiam.com/api/v1/goods/getGoodsList): actual reference names, manufacturer-labelled vegetarian variants, product image URLs and `info_en` records.
- Product-specific records: `https://server.hockkeekopitiam.com/api/v1/goods/getGoodsInfo?id=ID`. The public product page is `https://www.hockkeegroup.com/product?id=ID`. These URLs and the exact image source URL are saved per reference in `data/hock_kee_products.json` and `ProductSource`. The page URL pattern was checked against the manufacturer's own shop navigation code. Detail record 16 was cross-checked with the list.
- [Our story](https://www.hockkeegroup.com/our-story/): background for an original, short explanation of kopitiam/Nanyang café culture. We do not claim any connection or official partnership.
- [Manufacturer terms](https://www.hockkeegroup.com/terms-conditions/), intellectual property section: written permission is required for commercial reproduction. Public access alone does not grant reuse rights. **No manufacturer product photos are downloaded, hotlinked or republished.** Each official image URL and source name is retained as provenance; `image_rights_status = permission_required`.
- [Manufacturer halal page](https://www.hockkeegroup.com/halal/): not relied on for product certification. Product/plant-specific certificate scope, issuer, validity and traceability must be obtained; all product halal states remain `unknown`.

Product text is newly written in French and English, limited to identities and published facts. We deliberately omit health claims, price/stock fields, unsupported origin claims, and generic promotional statements. Full raw marketing text is not redistributed.

## Confirmed product references

| Official ID | Reference | Category | Confirmed format / dietary naming |
|---|---|---|---|
| 16 | Fragrance Oil Hock Kee Pan Mee | Pan Mee | Title says Vegetarian; pack weight unknown |
| 19 | Fragrance Oil Hock Kee Kolo Mee | Kolo Mee | Title says Vegetarian; pack weight unknown |
| 11 | Hock Kee White Coffee | Coffee | Serving states 40 g × 10 sachets, 400 g |
| 15 | Chilli Radish Hock Kee Pan Mee | Pan Mee | Title says Vegetarian; chilli variant |
| 18 | Mala Hock Kee Pan Mee | Pan Mee | Title says Vegetarian; Mala variant |
| 17 | Double Flavour Hock Kee Pan Mee | Pan Mee | Dietary state unknown |
| 21 | Chilli Radish Hock Kee Kolo Mee | Kolo Mee | Title says Vegetarian; chilli variant |
| 20 | Double Flavour Hock Kee Kolo Mee | Kolo Mee | Dietary state unknown |
| 24 | Clear Soup Pan Mee | Pan Mee | Dietary state unknown |
| 22 | Hock Kee Traditional Soup Noodle | Other noodles | Dietary state unknown |
| 32 | Hock Kee White Coffee 2 in 1 | Coffee | Serving states 25 g × 10 sachets, 250 g |
| 12 | Hock Kee Original Coffee | Coffee | Serving states 15 g × 10 bags, 150 g; description names Arabica, Robusta, Liberica |
| 10 | Hock Kee White Milk Tea | Tea | Serving states 40 g × 10 sachets, 400 g |
| 14 | Gula Melaka Milk Tea | Tea | Serving states 36 g × 10 sachets, 360 g |
| 25 | Pineapple Tart | Biscuits/snacks | Serving states 320 g and 10 individual packs; full composition unknown |

For every ID above, the source link, official image URL and rewritten text are recorded in the JSON seed file and database. The original official name, including Chinese text where supplied, is stored separately from display translations. The catalogue API's generic `weight` field is **not** interpreted as net weight. Noodle pack sizes remain null because no explicit serving/pack format was found in the text reviewed.

The noodle records share a generic series description. It mentions air drying, but does not supply product-specific ingredients, allergens, nutritional values or fixed cooking times. We qualify the shared nature of that information and do not turn it into a reviewed technical specification. Coffee/tea water quantities are recorded only for the specific published reference; their paraphrased English preparation text is shown as manufacturer information in the original language. No silent French translation of regulated fields is seeded.

## Unknowns and animal-origin considerations

- Complete product-specific ingredient lists, subingredients, additives, processing aids, allergens and cross-contact statements remain unknown for all seeded products. No “free from” claim is made.
- Pineapple Tart's text describes a buttery pastry but does not publish an ingredient declaration. This suggests a question about dairy, not proof of butter or animal content. `contains_animal_products` remains null for this reference too.
- Vegetarian-labelled noodles are not assumed vegan. Egg, milk, other animal-derived ingredients and cross-contact are unresolved. `contains_animal_products` remains null, even when `vegetarian` is true.
- Double Flavour and soup noodles may contain animal-origin ingredients, but the consulted text does not establish this. We do not infer pork, chicken, seafood, broth or their absence from traditional dish names.
- Milk tea and creamer-containing coffees need clarification of dairy/creamer composition and allergens. A milky description is not a complete ingredient declaration; animal-content booleans remain unknown.
- All products: actual manufacturing entity, manufacturing country, plant details, shelf life, storage conditions, batch/date coding, EAN/SKU, export history, net weights for noodles, packaging specifications, EU ingredient/additive acceptability and import documentation remain to be established.
- All EU states start `investigating`; all launch states start `candidate`. No product is marked available, compliant, halal-certified, vegan or non-spicy.
- Kaya, teh tarik, sauces and curry pastes are demand categories only. We did not find verified Hock Kee packaged references for these in the reviewed list. White Milk Tea is not relabelled as teh tarik. No fictional SKUs were created.
- Durian Coffee was not selected: its description appears shared with plain white coffee and needs product-specific clarification. Matcha and animal-derived bird’s nest/collagen drinks were not selected for this initial concept. No health benefit claims are repeated.

## Questions to send to the manufacturer (not sent)

1. Which legal entity manufactures and exports each selected SKU? Is it produced in Malaysia? Supply plant addresses and contacts.
2. Can you supply signed technical sheets, complete ingredients/subingredients, additives, allergen and cross-contact matrices, nutrition per 100 g/ml and per prepared serving?
3. What exactly does Vegetarian mean for each noodle SKU? Are eggs, dairy, animal-derived flavourings or processing aids present?
4. What are the net weights, units/carton, EANs, export SKUs, best-before format, shelf life at manufacture/dispatch and storage requirements?
5. Which exact products/plants have halal certificates, from whom, for which dates and scope? Supply verifiable documents.
6. Has each SKU previously been exported to the EU? Which importer and regulatory documents were used? Are there animal-origin/composite-product restrictions to assess with an import specialist?
7. Can French/EU labelling and translations be supplied for independent review? What traceability and recall procedures apply?
8. Can we obtain written permission to reproduce specific product images in France/EU for a pre-launch catalogue and later commerce? Which approved assets may we use?
9. What are MOQs, trade prices, sample terms, Incoterms, lead times and export logistics? No public EU pricing can be promised before landed-cost analysis.

## Privacy and regulatory editorial references

- [CNIL: cookies and trackers](https://www.cnil.fr/fr/cookies-et-autres-traceurs/que-dit-la-loi): technical preferences/security cookie only; no advertising/analytics identifier. Signed attribution carries campaign strings through links without adding a marketing cookie. This implementation choice is not a legal compliance certification.
- [CNIL: retention](https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees): purpose-based retention. The site's 30-day / 24-month / 90-day periods are chosen project defaults, not purported mandatory statutory periods.
- [European Commission: food information to consumers](https://food.ec.europa.eu/food-safety/labelling-and-nutrition/food-information-consumers-legislation_en): reference for cautious wording about label, allergen and food-information review. This is not a product eligibility determination. Operator, provider and legal details must be completed and reviewed before public collection.

## Original visual assets

Catalogue placeholders are original SVG illustrations, explicitly labelled, and do not reproduce manufacturer packaging. The editorial hero was created using the built-in imagegen tool; it is labelled as an AI-created generic serving suggestion, not a product photo. Files: `app/assets/images/kopitiam-table.webp` and `kopitiam-table-small.webp`. Generation prompt: warm natural-light editorial still life on a honey-toned kopitiam table, ivory bowl of dry ribbon noodles with dark sauce/spring onion, small chilli dish, traditional coffee cup, chopsticks/linen; no people, text, packaging, branding or trademarks. See `data/visual_assets.md` for the full prompt.
