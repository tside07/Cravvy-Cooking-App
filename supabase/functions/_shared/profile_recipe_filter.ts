// Profile-aware recipe filtering for meal plans.
// Keep logic in sync with lib/core/utils/profile_recipe_filter.dart

export const SOFT_DIETS = new Set([
  "No Specific Diet",
  "Eat Clean",
  "High-Protein",
  "Intermittent Fasting",
]);

export const AVOID_TOKEN_MAP: Record<string, string[]> = {
  Peanuts: ["peanut", "peanuts", "đậu phộng", "lac"],
  Shellfish: ["shellfish", "shrimp", "prawn", "crab", "lobster", "tôm", "cua"],
  Dairy: ["dairy", "milk", "cheese", "cream", "butter", "yogurt", "sữa", "phô mai"],
  Gluten: ["gluten", "wheat", "flour", "bread", "mì", "bánh mì"],
  Eggs: ["egg", "eggs", "trứng"],
  Soy: ["soy", "tofu", "đậu nành", "tương"],
  "Tree Nuts": ["almond", "walnut", "cashew", "pecan", "hazelnut", "hạnh nhân", "óc chó"],
  Fish: ["fish", "salmon", "tuna", "cá"],
  "No Pork": ["pork", "heo", "thịt heo"],
  "No Beef": ["beef", "bò", "thịt bò"],
  "No Seafood": [
    "seafood",
    "fish",
    "shellfish",
    "shrimp",
    "prawn",
    "crab",
    "lobster",
    "tôm",
    "cua",
    "cá",
  ],
  "No Spicy": ["spicy", "chili", "chilli", "pepper", "cay", "ớt"],
  "No Raw Foods": ["raw", "sống", "sashimi"],
};

const MEAT_FISH_TOKENS = [
  "pork",
  "beef",
  "chicken",
  "meat",
  "fish",
  "seafood",
  "shellfish",
  "shrimp",
  "prawn",
  "crab",
  "lobster",
  "salmon",
  "tuna",
  "thịt",
  "gà",
  "bò",
  "heo",
  "cá",
  "tôm",
  "cua",
];

const ANIMAL_PRODUCT_TOKENS = [
  ...MEAT_FISH_TOKENS,
  "egg",
  "eggs",
  "dairy",
  "milk",
  "cheese",
  "cream",
  "butter",
  "yogurt",
  "honey",
  "gelatin",
  "trứng",
  "sữa",
  "phô mai",
];

const GLUTEN_TOKENS = [
  "gluten",
  "wheat",
  "flour",
  "bread",
  "noodle",
  "pasta",
  "mì",
  "bánh mì",
];

const SUGAR_TOKENS = [
  "sugar",
  "sweet",
  "dessert",
  "candy",
  "syrup",
  "đường",
  "ngọt",
];

export function normalizeDietToken(value: string): string {
  return value.toLowerCase().replaceAll("-", " ").trim();
}

export function expandAvoidTokens(label: string): string[] {
  const trimmed = label.trim();
  if (!trimmed) return [];
  return AVOID_TOKEN_MAP[trimmed] ?? [trimmed.toLowerCase()];
}

export function recipeCorpus(r: Record<string, unknown>): string {
  const tags = ((r.tags as string[]) ?? []).join(" ");
  const ingredients = ((r.ingredients as string[]) ?? []).join(" ");
  return `${String(r.name ?? "")} ${tags} ${ingredients}`.toLowerCase();
}

function corpusContainsAny(corpus: string, tokens: string[]): boolean {
  return tokens.some((t) => corpus.includes(t));
}

export function violatesAvoidFoods(
  r: Record<string, unknown>,
  avoidFoods: string[],
): boolean {
  if (!avoidFoods.length) return false;
  const corpus = recipeCorpus(r);
  for (const item of avoidFoods) {
    const tokens = expandAvoidTokens(item);
    if (corpusContainsAny(corpus, tokens)) return true;
  }
  return false;
}

function passesSingleDiet(
  r: Record<string, unknown>,
  diet: string,
): boolean {
  const corpus = recipeCorpus(r);
  const tags = ((r.tags as string[]) ?? []).map(normalizeDietToken);
  const carbs = Number(r.carbs ?? 0);

  switch (diet) {
    case "Vegan":
      return !corpusContainsAny(corpus, ANIMAL_PRODUCT_TOKENS);
    case "Vegetarian":
      return !corpusContainsAny(corpus, MEAT_FISH_TOKENS);
    case "Gluten-Free":
      if (tags.some((t) => t.includes("gluten free"))) return true;
      return !corpusContainsAny(corpus, GLUTEN_TOKENS);
    case "Keto":
      if (tags.some((t) => t.includes("keto"))) return true;
      return carbs <= 25;
    case "Low-Carb":
      if (tags.some((t) => t.includes("low carb"))) return true;
      return carbs <= 45;
    case "Low-Sugar":
      if (tags.some((t) => t.includes("low sugar"))) return true;
      return !corpusContainsAny(corpus, SUGAR_TOKENS);
    default:
      return true;
  }
}

export function passesDietHardFilters(
  r: Record<string, unknown>,
  diets: string[],
): boolean {
  if (!diets.length || diets.includes("No Specific Diet")) return true;

  const active = diets.filter((d) => !SOFT_DIETS.has(d));
  if (!active.length) return true;

  return active.every((diet) => passesSingleDiet(r, diet));
}

export function matchesProfile(
  r: Record<string, unknown>,
  profile: Record<string, unknown>,
): boolean {
  const avoid = ((profile.avoid_foods as string[]) ?? []);
  const diets = ((profile.diets as string[]) ?? []);
  if (violatesAvoidFoods(r, avoid)) return false;
  if (!passesDietHardFilters(r, diets)) return false;
  return true;
}

export function filterRecipesForProfile(
  recipes: Record<string, unknown>[],
  profile: Record<string, unknown>,
): Record<string, unknown>[] {
  return recipes.filter((r) => matchesProfile(r, profile));
}

function tagMatchesDiet(tag: string, diet: string): boolean {
  const normalizedTag = normalizeDietToken(tag);
  const normalizedDiet = normalizeDietToken(diet);
  return normalizedTag.includes(normalizedDiet) ||
    normalizedDiet.includes(normalizedTag);
}

export function scoreRecipe(
  r: Record<string, unknown>,
  profile: Record<string, unknown>,
): number {
  const goal = String(profile.goal ?? "maintain");
  const calories = Number(r.calories ?? 0);
  const protein = Number(r.protein ?? 0);
  const tags = ((r.tags as string[]) ?? []);
  const diets = ((profile.diets as string[]) ?? []);

  let score = 0;
  switch (goal) {
    case "lose-weight":
      if (calories < 350) score += 3;
      if (calories < 450) score += 1;
      if (tags.some((t) => normalizeDietToken(t).includes("low carb"))) {
        score += 2;
      }
      break;
    case "build-muscle":
      if (protein >= 30) score += 4;
      if (protein >= 20) score += 2;
      if (tags.some((t) => normalizeDietToken(t).includes("high protein"))) {
        score += 2;
      }
      break;
    default:
      if (calories < 600) score += 1;
  }

  for (const diet of diets) {
    if (SOFT_DIETS.has(diet)) continue;
    if (tags.some((t) => tagMatchesDiet(t, diet))) score += 3;
  }
  return score;
}
