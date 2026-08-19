export interface CndIssue {
  file: string;
  line?: number;
  pattern: string;
  message: string;
  fix: string;
}

export function checkCndFiles(projectDir: string): {
  score: number;
  issues: CndIssue[];
  filesChecked: number;
};
