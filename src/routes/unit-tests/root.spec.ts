import { beforeEach, describe, expect, it } from '@jest/globals';
import request from 'supertest';
import express, { type Express } from 'express';
import rootRouter from "../root.js";

describe('Root Routes', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use('/', rootRouter);
  });

  describe('GET /', () => {
    it('should return 200 with HTML content when Accept header includes text/html', async () => {
      const response = await request(app)
        .get('/')
        .set('Accept', 'text/html');

      expect(response.status).toBe(200);
      expect(response.type).toBe('text/html');
      expect(response.text).toContain('Application Endpoints');
      expect(response.text).toContain('GET /items');
      expect(response.text).toContain('POST /items');
      expect(response.text).toContain('GET /alive');
      expect(response.text).toContain('GET /ready');
    });

    it('should return 406 when Accept header does not include text/html', async () => {
      const response = await request(app)
        .get('/')
        .set('Accept', 'application/json');

      expect(response.status).toBe(406);
      expect(response.text).toContain('Not Acceptable');
    });
  });
});
