import * as crypto from 'crypto';

// 生成签名
function genSign(timestamp: string, secret: string): string {
  const stringToSign = `${timestamp}\n${secret}`;
  const hmac = crypto.createHmac('sha256', stringToSign);
  const signature = hmac.update('').digest('base64');
  return signature;
}

// 发送飞书消息
export async function sendFeishuMessage(webhookUrl: string, secret: string, message: string) {
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const sign = genSign(timestamp, secret);

  // 构建请求体
  const payload = {
    timestamp,
    sign,
    msg_type: 'text',
    content: {
      text: message,
    },
  };
  // 发送请求
  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });
  // 如果请求失败，打印错误信息
  if (!response.ok) {
    const errorText = await response.text();
    if (process.env.NODE_ENV === 'development') {
      console.error(`消息发送失败: ${response.status} - ${errorText}`);
    }
    return { msg: 'failed' }
  }
  // 如果请求成功
  const result = await response.json();
  return { msg: result.msg }
}