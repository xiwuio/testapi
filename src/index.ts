import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { sendFeishuMessage } from './feishu-bot'
import "dotenv/config";

if (!process.env.FEISHU_BOT_WEBHOOK || !process.env.FEISHU_BOT_SECRET) {
  throw new Error('FEISHU_BOT_WEBHOOK or FEISHU_BOT_SECRET is not set')
}

const app = new Hono()

app.use(logger(), cors())

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.post('/api/payment/callback', async (c) => {
  const requestBody = await c.req.json();

  console.log('--------------------------------')
  // 打印所有请求头
  console.log('请求头 ->', c.req.header())
  // 打印所有请求体
  console.log('请求体 ->', requestBody)
  // 打印所有查询参数
  console.log('查询参数 ->', c.req.query())
  console.log('--------------------------------')

  const res = await sendFeishuMessage(
    process.env.FEISHU_BOT_WEBHOOK || '',
    process.env.FEISHU_BOT_SECRET || '',
    `请求头：${JSON.stringify(c.req.header(), null, 2)}\n\n请求体：${JSON.stringify(requestBody, null, 2)}\n\n查询参数：${JSON.stringify(c.req.query(), null, 2)}`
  );

  if (res.msg === 'failed') {
    console.log('飞书消息发送失败')
  }
  return c.json({ success: true })
})

export default {
  port: 8000,
  fetch: app.fetch,
}
