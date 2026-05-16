-- Run in Supabase Dashboard → SQL Editor (after creating bucket "avatars" as PUBLIC)

-- Public read for profile images
CREATE POLICY "avatars_public_read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow app uploads under profiles/ (uses anon key from Flutter)
CREATE POLICY "avatars_insert_profiles"
ON storage.objects FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = 'profiles'
);

CREATE POLICY "avatars_update_profiles"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'profiles');

CREATE POLICY "avatars_delete_profiles"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'profiles');
