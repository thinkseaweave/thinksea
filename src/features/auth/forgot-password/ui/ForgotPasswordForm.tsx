import { useState } from 'react';
import { authApi } from '@/entities/user';
import { Button, Input, Label, Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/shared/ui';

export function ForgotPasswordForm() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      await authApi.resetPasswordForEmail(email);
      setSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다.');
    } finally {
      setIsLoading(false);
    }
  };

  if (success) {
    return (
      <Card className="w-full max-w-lg">
        <CardHeader>
          <CardTitle>이메일 전송 완료</CardTitle>
          <CardDescription>비밀번호 재설정 링크가 전송되었습니다</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="p-3 text-sm text-green-600 bg-green-50 border border-green-200 rounded-md">
            <p className="font-medium mb-2">이메일을 확인해주세요!</p>
            <p className="text-green-700">
              <strong>{email}</strong>로 비밀번호 재설정 링크를 보냈습니다.
            </p>
            <p className="mt-2 text-green-700">
              이메일의 링크를 클릭하여 비밀번호를 재설정하세요.
            </p>
          </div>
          <div className="text-sm text-muted-foreground space-y-2">
            <p>💡 이메일이 오지 않나요?</p>
            <ul className="list-disc list-inside space-y-1 text-xs">
              <li>스팸/정크 메일함을 확인해주세요</li>
              <li>이메일 주소가 정확한지 확인해주세요</li>
              <li>몇 분 정도 소요될 수 있습니다</li>
            </ul>
          </div>
        </CardContent>
        <CardFooter className="flex flex-col gap-2">
          <Button
            type="button"
            variant="outline"
            className="w-full"
            onClick={() => {
              setSuccess(false);
              setEmail('');
            }}
          >
            다시 시도하기
          </Button>
          <a href="/auth/login" className="w-full">
            <Button type="button" variant="ghost" className="w-full">
              로그인으로 돌아가기
            </Button>
          </a>
        </CardFooter>
      </Card>
    );
  }

  return (
    <Card className="w-full max-w-lg">
      <CardHeader>
        <CardTitle>비밀번호 찾기</CardTitle>
        <CardDescription>
          가입하신 이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다
        </CardDescription>
      </CardHeader>
      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-4">
          {error && (
            <div className="p-3 text-sm text-red-500 bg-red-50 border border-red-200 rounded-md">
              {error}
            </div>
          )}
          <div className="space-y-2">
            <Label htmlFor="email">이메일</Label>
            <Input
              id="email"
              type="email"
              placeholder="name@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={isLoading}
            />
          </div>
        </CardContent>
        <CardFooter className="flex flex-col gap-4">
          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? '전송 중...' : '재설정 링크 보내기'}
          </Button>
          <div className="text-sm text-center text-muted-foreground">
            <a href="/auth/login" className="text-primary hover:underline">
              로그인으로 돌아가기
            </a>
          </div>
        </CardFooter>
      </form>
    </Card>
  );
}
