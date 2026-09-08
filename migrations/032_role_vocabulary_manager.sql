-- ============================================================================
-- 032_role_vocabulary_manager.sql — אוצר מילים אחד לתפקיד
-- ============================================================================
--
-- ⛔ **רץ במסד.**
--
-- ⛔⛔ **`senior` ⟵ `manager`:** ⚠️ שלוש האפליקציות שיש בהן כניסה השוו
--    כל אחת מול שם תפקיד משלה — `admin`/`senior`/`junior` כאן,
--    `admin` בשכר, ו-`owner`/`manager` בגיוס. ⭐ **הנימוק:** ⛔ שלושה
--    אוצרות מילים לאותו מושג הם שלוש הזדמנויות לטעות, ⚠️ ובדיקה
--    שהועתקה בין האפליקציות משווה מול שם שאינו קיים ⛔ ונכשלת פתוח.
--    ⭐ מעכשיו `admin` הוא המורשה ו-`manager` מי שאינו, ⛔ ודרגת
--    הביניים `junior` נשארת כאן בלבד — היא הדרגה השלישית של מטריצת
--    ההרשאות, ⚠️ ואין לה מקבילה בשתיים האחרות.
--
-- ⚠️ **שני צדדים באותה מיגרציה:** ⛔ עמודת התפקיד ב-`ys_users`,
--    ⛔ ומפתחות המטריצה שב-`ys_settings.ys_perms` — ⭐ שינוי באחד בלבד
--    היה משאיר משתמש `manager` מול מטריצה שמכירה `senior` בלבד,
--    ⛔ וההרשאה הייתה נופלת ל-`none` בשקט.
--
-- ⚠️ **וגם אילוץ ה-`check` מיושר** — ⛔ הוא מנה את שלושת השמות הישנים,
--    ⭐ ועדכון בלי החלפתו נדחה במסד: ⚠️ האילוץ הוא הצהרת אוצר המילים
--    ⛔ ולא קישוט.
--
-- ⛔ אידמפוטנטית: ⚠️ הרצה שנייה אינה מוצאת `senior` ואינה משנה דבר.
-- ============================================================================

alter table ys_users drop constraint if exists ys_users__new_role_check;

update ys_users
   set role = 'manager',
       updated_at = updated_at
 where role = 'senior';

update ys_settings
   set value = replace(value, '"senior"', '"manager"'),
       updated_at = updated_at
 where key = 'ys_perms'
   and value like '%"senior"%';

alter table ys_users
  add constraint ys_users__new_role_check
  check (role = any (array['admin'::text, 'manager'::text, 'junior'::text]));
