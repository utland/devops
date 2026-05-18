import request from "supertest";
import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import express, { type Express } from 'express';
import healthRouter from '../health.js';
import db from '../../database/connection.js';

jest.mock('../../database/connection');

const mockDb = db as jest.Mocked<typeof db>;

describe('Health Routes', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/', healthRouter);
    jest.clearAllMocks();
  });

  describe('GET /alive', () => {
    it('should return 200 OK status', async () => {
      const response = await request(app).get('/alive');

      expect(response.status).toBe(200);
    });
  });

  describe('GET /ready', () => {
    it('should return 200 OK when database is available', async () => {
      mockDb.query.mockResolvedValueOnce({} as never);

      const response = await request(app).get('/ready');

      expect(response.status).toBe(200);
      expect(mockDb.query).toHaveBeenCalledWith('SELECT 1');
    });

    it('should return 503 when database is unavailable', async () => {
      mockDb.query.mockRejectedValueOnce(new Error('Connection refused') as never);

      const response = await request(app).get('/ready');

      expect(response.status).toBe(503);
    });
  });
});
