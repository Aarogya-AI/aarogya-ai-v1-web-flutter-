-- Run this in Supabase SQL Editor to restore your database
-- Go to: SQL Editor > New Query > Paste this > Run

-- 1. Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create the health_parameters table
CREATE TABLE IF NOT EXISTS public.health_parameters (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL,
    name text NOT NULL,
    unit text NOT NULL,
    value double precision NOT NULL,
    history jsonb DEFAULT '[]'::jsonb,
    last_updated timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- 3. Enable Row Level Security
ALTER TABLE public.health_parameters ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS policy so users can only see their own data
CREATE POLICY "Users can view own health parameters" ON public.health_parameters
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own health parameters" ON public.health_parameters
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own health parameters" ON public.health_parameters
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own health parameters" ON public.health_parameters
    FOR DELETE USING (auth.uid() = user_id);

-- 5. Insert your existing data
INSERT INTO public.health_parameters (id, user_id, name, unit, value, history, last_updated) VALUES
('20aa3fb5-0a7b-47f1-96f6-9a96f7bc6e8b', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Blood Glucose Post Prandial', 'mg/dl', 11, '[{"date": "2025-05-28T10:19:40.090", "value": 111}, {"date": "2025-05-28T11:00:36.425", "value": 140}, {"date": "2025-05-28T11:01:15.143", "value": 111}, {"date": "2025-06-02T13:33:29.267", "value": 140}, {"date": "2025-06-02T14:01:49.758", "value": 11}]', '2025-06-02 14:01:49.758+00'),
('308c55ca-b94e-4bbd-88be-fa10bf3ed74c', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Serum Creatinine', 'mg/dL', 1.1, '[{"date": "2025-05-27T15:09:47.080", "value": 1.3}, {"date": "2025-05-27T15:11:03.508", "value": 1.3}, {"date": "2025-05-27T15:21:28.942", "value": 1.3}, {"date": "2025-05-27T17:29:36.226", "value": 1.3}, {"date": "2025-05-28T10:19:40.090", "value": 1.4}, {"date": "2025-05-28T11:00:36.425", "value": 1.1}, {"date": "2025-05-28T11:01:15.143", "value": 1.4}, {"date": "2025-06-02T13:33:29.267", "value": 1.1}, {"date": "2025-06-02T14:01:49.758", "value": 1.1}]', '2025-06-02 14:01:49.758+00'),
('dcd82f37-6653-4d8f-bbae-183526d74488', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Glycosylated Hemoglobin (HBA1C)', '%', 6.4, '[{"date": "2025-06-02T13:33:29.267", "value": 6.4}, {"date": "2025-06-02T14:01:49.758", "value": 6.4}]', '2025-06-02 14:01:49.758+00'),
('ebd77b8f-c2dc-4532-a3cd-e12ff2929349', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Estimated Average Glucose', 'mg/dl', 137, '[{"date": "2025-05-28T10:19:40.090", "value": 137}, {"date": "2025-05-28T11:00:36.425", "value": 137}, {"date": "2025-05-28T11:01:15.143", "value": 137}, {"date": "2025-06-02T13:33:29.267", "value": 137}, {"date": "2025-06-02T14:01:49.758", "value": 137}]', '2025-06-02 14:01:49.758+00'),
('27681dae-e2b6-45d6-839a-8759f50aee63', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Glycosylated Hemoglobin', '%', 6.4, '[{"date": "2025-05-28T10:19:40.090", "value": 6.4}, {"date": "2025-05-28T11:00:36.425", "value": 6.4}, {"date": "2025-05-28T11:01:15.143", "value": 6.4}]', '2025-05-28 11:01:15.143+00'),
('398a611e-e2a6-48d6-af9d-7db8a5a0c681', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Age', 'Years', 0, '[{"date": "2025-05-27T15:09:47.080", "value": 51}, {"date": "2025-05-27T15:11:03.508", "value": 51}, {"date": "2025-05-27T15:21:28.942", "value": 51}, {"date": "2025-05-27T17:29:36.226", "value": 51}, {"date": "2025-06-02T15:22:03.096", "value": 0}]', '2025-06-02 15:22:03.096+00'),
('14ba434b-5b97-4d60-95a1-be762fd1d77a', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Blood Glucose Fasting', 'mg/dL', 106, '[{"date": "2025-05-27T17:48:12.432", "value": 110}, {"date": "2025-05-27T17:54:22.080", "value": 110}, {"date": "2025-05-28T11:02:09.913", "value": 106}]', '2025-05-28 11:02:09.913+00'),
('71f8db94-0c0a-4dcf-bc45-229080afb566', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Blood Glucose Post Prandial', 'mg/L', 11, '[{"date": "2025-05-28T11:02:09.913", "value": 11}]', '2025-05-28 11:02:09.913+00'),
('ed1bcb10-64b8-4291-ac92-b1d22792c064', 'a0116b83-0ed5-41a6-995c-e793d9c68013', 'Glycosylated Hemoglobin', '%', 6.4, '[{"date": "2025-06-02T17:42:00.091", "value": 6.4}]', '2025-06-02 17:42:00.091+00'),
('f4a5366a-7a32-4896-8c0d-b020320308a7', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Blood Sugar', 'mg/dl', 54, '[{"date": "2025-06-02T15:22:36.012", "value": 54}]', '2025-06-02 15:22:36.012+00'),
('6093ffde-b9cd-4a84-a5da-da7c038b942d', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Creatinine', 'mg/dl', 0.6, '[{"date": "2025-06-02T15:22:36.012", "value": 0.6}]', '2025-06-02 15:22:36.012+00'),
('7e9e78cc-1c48-495d-9d93-716c01f6a27e', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Age', 'Years', 51, '[{"date": "2025-05-27T17:48:12.432", "value": 51}, {"date": "2025-05-27T17:54:22.080", "value": 51}]', '2025-05-27 17:54:22.08+00'),
('4256ba7a-5f13-4a5b-97b6-c9a89c8cd488', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Serum Creatinine', 'mg/dL', 1.1, '[{"date": "2025-05-27T17:48:12.432", "value": 1.3}, {"date": "2025-05-27T17:54:22.080", "value": 1.3}, {"date": "2025-05-28T11:02:09.913", "value": 1.1}]', '2025-05-28 11:02:09.913+00'),
('458785f4-7f58-42b4-bf8a-7a4693e59126', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Glycosylated Hemoglobin (HBA1C)', '%', 6.4, '[{"date": "2025-05-28T11:02:09.913", "value": 6.4}]', '2025-05-28 11:02:09.913+00'),
('a261babb-be61-462c-90ec-ad38e8333d53', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Hemoglobin', 'g/dl', 15, '[{"date": "2025-06-02T15:22:36.012", "value": 15}]', '2025-06-02 15:22:36.012+00'),
('b658fbe8-7414-426b-90ac-78b9482b1813', 'bf22c001-0cde-4d74-b238-97770f831ec2', 'Blood Glucose Fasting', 'mg/dL', 106, '[{"date": "2025-05-27T15:09:47.080", "value": 110}, {"date": "2025-05-27T15:11:03.508", "value": 110}, {"date": "2025-05-27T15:21:28.942", "value": 110}, {"date": "2025-05-27T17:29:36.226", "value": 110}, {"date": "2025-05-28T10:19:40.090", "value": 106}, {"date": "2025-05-28T11:00:36.425", "value": 106}, {"date": "2025-05-28T11:01:15.143", "value": 106}, {"date": "2025-06-02T13:33:29.267", "value": 106}, {"date": "2025-06-02T14:01:49.758", "value": 106}]', '2025-06-02 14:01:49.758+00'),
('96e4d407-1d49-4293-8010-ccf36db7a7fd', 'a0116b83-0ed5-41a6-995c-e793d9c68013', 'Blood Glucose Fasting', 'mg/dL', 106, '[{"date": "2025-06-02T17:42:00.091", "value": 106}]', '2025-06-02 17:42:00.091+00'),
('b64404c8-a2ca-4c0a-a3c1-9071c0563193', '3bc9a010-8d85-4d47-b04b-0ba201247fd9', 'Estimated Average Glucose', 'mg/L', 137, '[{"date": "2025-05-28T11:02:09.913", "value": 137}]', '2025-05-28 11:02:09.913+00'),
('34d82b39-2cf3-4bc0-83d6-364e2739b295', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Age', 'Years', 51, '[{"date": "2025-05-28T12:36:21.122", "value": 51}]', '2025-05-28 12:36:21.122+00'),
('49b59c32-d7d6-4fe0-aa1b-ed54942787c0', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Blood Glucose Fasting', 'mg/dL', 106, '[{"date": "2025-05-28T12:36:21.122", "value": 110}, {"date": "2025-05-28T12:37:49.298", "value": 106}]', '2025-05-28 12:37:49.298+00'),
('2ac62d1d-6907-47ae-b6e1-1cc0cf8b6125', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Blood Glucose Post Prandial', 'mg/L', 11, '[{"date": "2025-05-28T12:37:49.298", "value": 11}]', '2025-05-28 12:37:49.298+00'),
('93544806-4651-486d-8164-3f5d2fa1f65e', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Serum Creatinine', 'mg/dL', 1.1, '[{"date": "2025-05-28T12:36:21.122", "value": 1.3}, {"date": "2025-05-28T12:37:49.298", "value": 1.1}]', '2025-05-28 12:37:49.298+00'),
('2d47609a-0288-432d-8c02-46d271653b23', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Glycosylated Hemoglobin (HBA1C)', '%', 6.4, '[{"date": "2025-05-28T12:37:49.298", "value": 6.4}]', '2025-05-28 12:37:49.298+00'),
('5e1dce3f-fca8-4684-ae5c-5ac1c82239f0', 'c48863f9-ecb5-4be6-b190-61cdd293a8a9', 'Estimated Average Glucose', 'mg/L', 137, '[{"date": "2025-05-28T12:37:49.298", "value": 137}]', '2025-05-28 12:37:49.298+00'),
('63dcc39b-9b35-47b8-ad57-be7e4788c9e4', 'a0116b83-0ed5-41a6-995c-e793d9c68013', 'Blood Glucose Post Prandial', 'mg/dL', 11, '[{"date": "2025-06-02T17:42:00.091", "value": 11}]', '2025-06-02 17:42:00.091+00'),
('4b2f4fc9-6d09-4430-934f-91e1755e11b0', 'a0116b83-0ed5-41a6-995c-e793d9c68013', 'Serum Creatinine', 'mg/dL', 1.1, '[{"date": "2025-06-02T17:42:00.091", "value": 1.1}]', '2025-06-02 17:42:00.091+00'),
('ff32edd7-dff7-445b-8828-9e6a49304d6c', 'a0116b83-0ed5-41a6-995c-e793d9c68013', 'Estimated Average Glucose', 'mg/dL', 137, '[{"date": "2025-06-02T17:42:00.091", "value": 137}]', '2025-06-02 17:42:00.091+00')
ON CONFLICT (id) DO NOTHING;

-- Done! Your database is restored.
