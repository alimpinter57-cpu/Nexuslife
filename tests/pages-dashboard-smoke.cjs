const { chromium } = require("playwright");
const assert = require("node:assert/strict");

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const errors = [];
  page.on("pageerror", error => errors.push(error.message));

  try {
    await page.goto("http://127.0.0.1:4173/");
    await page.evaluate(() => localStorage.clear());
    await page.reload();

    // Theme toggle persists after reload.
    await page.locator("#themeToggle").click();
    assert.equal(await page.locator("body").getAttribute("data-theme"), "light");
    await page.reload();
    assert.equal(await page.locator("body").getAttribute("data-theme"), "light");

    // Habit: create, complete, reload, and delete.
    await page.locator('[data-page="Habit Tracker"]').first().click();
    await page.locator("#habitName").fill("CI smoke habit");
    await page.locator("#habitDetail").fill("5 menit");
    await page.locator('#addForm button[type="submit"]').click();
    const habit = page.locator("#allHabits .habit").filter({ hasText: "CI smoke habit" });
    await habit.waitFor();
    await habit.locator("[data-toggle]").click();
    assert.equal(await habit.locator(".check").getAttribute("aria-label"), "Tandai belum selesai");
    await page.reload();
    await page.locator('[data-page="Habit Tracker"]').first().click();
    await page.locator("#allHabits .habit").filter({ hasText: "CI smoke habit" }).waitFor();
    await page.locator("#allHabits .habit").filter({ hasText: "CI smoke habit" }).locator("[data-delete]").click();
    await page.locator("#allHabits .habit").filter({ hasText: "CI smoke habit" }).waitFor({ state: "detached" });

    // Notes: create and delete.
    await page.locator('[data-page="Notes"]').first().click();
    await page.locator("#noteTitle").fill("CI smoke note");
    await page.locator("#noteBody").fill("Notes persistence check");
    await page.locator('#noteForm button[type="submit"]').click();
    const note = page.locator("#notesList article").filter({ hasText: "CI smoke note" });
    await note.waitFor();
    await note.locator("[data-note-delete]").click();
    await note.waitFor({ state: "detached" });

    // Workout: create and delete.
    await page.locator('[data-page="Workout"]').first().click();
    await page.locator("#workoutExercise").fill("CI smoke push-up");
    await page.locator("#workoutSets").fill("2");
    await page.locator("#workoutReps").fill("6");
    await page.locator('#workoutForm button[type="submit"]').click();
    const workout = page.locator("#workoutList article").filter({ hasText: "CI smoke push-up" });
    await workout.waitFor();
    await workout.locator("[data-workout-delete]").click();
    await workout.waitFor({ state: "detached" });

    assert.deepEqual(errors, [], "Browser reported JavaScript errors");
    console.log("PASS: theme persistence, habit CRUD/persistence, Notes CRUD, Workout CRUD; no page errors.");
  } finally {
    await browser.close();
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
