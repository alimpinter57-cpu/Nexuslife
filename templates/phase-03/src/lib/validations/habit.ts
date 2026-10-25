import { z } from "zod"

const habitFrequency = z.enum(["DAILY", "WEEKLY", "MONTHLY", "CUSTOM"])

export const createHabitSchema = z.object({
  name: z.string().trim().min(1, "Nama habit wajib diisi").max(120),
  description: z.string().trim().max(1000).optional().nullable(),
  icon: z.string().trim().max(32).optional().nullable(),
  color: z.string().trim().max(32).optional().nullable(),
  frequency: habitFrequency.optional().default("DAILY"),
  customDays: z.array(z.number().int().min(0).max(6)).max(7).optional().default([]),
  targetPerPeriod: z.number().int().min(1).max(100).optional().default(1),
}).strict().superRefine((value, context) => {
  if (value.frequency === "CUSTOM" && value.customDays.length === 0) {
    context.addIssue({ code: z.ZodIssueCode.custom, path: ["customDays"], message: "Pilih setidaknya satu hari untuk jadwal khusus." })
  }
})

export type CreateHabitInput = z.infer<typeof createHabitSchema>
