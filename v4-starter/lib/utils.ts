export function formatStat(value: number | null | undefined) {
  return value === null || value === undefined || Number.isNaN(value) ? '—' : String(value);
}
export function teamSortValue(team: string) {
  if (team === '17U') return 1;
  if (team === '16U') return 2;
  if (team === '15U') return 3;
  return 4;
}
