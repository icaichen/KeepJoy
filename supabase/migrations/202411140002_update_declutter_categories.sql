-- Merge books and papers into booksDocuments and add electronics category
ALTER TABLE IF EXISTS public.declutter_items
  DROP CONSTRAINT IF EXISTS declutter_items_category_check;

UPDATE public.declutter_items
SET category = 'booksDocuments'
WHERE category IN ('books', 'papers');

ALTER TABLE IF EXISTS public.declutter_items
  ADD CONSTRAINT declutter_items_category_check
  CHECK (category IN ('clothes', 'booksDocuments', 'electronics', 'beauty', 'sentimental', 'miscellaneous'));
