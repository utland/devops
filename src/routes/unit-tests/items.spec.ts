import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import express, { type Express } from 'express';
import itemsRouter from '../items';
import db from '../../database/connection';

jest.mock('../../database/connection');

const mockDb = db as jest.Mocked<typeof db>;

describe('Items Routes', () => {
  let app: Express;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/', itemsRouter);
    jest.clearAllMocks();
  });

  describe('GET /', () => {
    it('should return 200 with items in JSON format', async () => {
      const mockItems = [
        { name: 'Item 1', quantity: 10 },
        { name: 'Item 2', quantity: 20 },
      ];

      mockDb.query.mockResolvedValueOnce({ rows: mockItems } as never);

      const response = await request(app)
        .get('/')
        .set('Accept', 'application/json');

      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockItems);
      expect(mockDb.query).toHaveBeenCalledWith('SELECT name, quantity FROM items');
    });

    it('should return 200 with items in HTML format', async () => {
      const mockItems = [
        { name: 'Item 1', quantity: 10 },
      ];

      mockDb.query.mockResolvedValueOnce({ rows: mockItems } as never);

      const response = await request(app)
        .get('/')
        .set('Accept', 'text/html');

      expect(response.status).toBe(200);
      expect(response.text).toContain('<table');
      expect(response.text).toContain('Item 1');
    });

    it('should return 500 on database error', async () => {
      mockDb.query.mockRejectedValueOnce(new Error('DB Error') as never);

      const response = await request(app)
        .get('/')
        .set('Accept', 'application/json');

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to get items' });
    });
  });

  describe('GET /:id', () => {
    it('should return 200 with item details in JSON format', async () => {
      const mockItem = {
        inventory_id: '123',
        name: 'Test Item',
        quantity: 15,
        created_at: '2024-01-01',
      };

      mockDb.query.mockResolvedValueOnce({ rows: [mockItem] } as never);

      const response = await request(app)
        .get('/123')
        .set('Accept', 'application/json');

      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockItem);
      expect(mockDb.query).toHaveBeenCalledWith(
        'SELECT * FROM items WHERE item_id = $1',
        ['123']
      );
    });

    it('should return 404 when item not found', async () => {
      mockDb.query.mockResolvedValueOnce({ rows: [] } as never);

      const response = await request(app)
        .get('/999')
        .set('Accept', 'application/json');

      expect(response.status).toBe(404);
      expect(response.body).toEqual({ error: 'Item not found' });
    });

    it('should return 500 on database error', async () => {
      mockDb.query.mockRejectedValueOnce(new Error('DB Error') as never);

      const response = await request(app)
        .get('/123')
        .set('Accept', 'application/json');

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to get item' });
    });
  });

  describe('POST /', () => {
    it('should create an item and return 201', async () => {
      mockDb.query.mockResolvedValueOnce({ rows: [] } as never);

      const response = await request(app)
        .post('/')
        .send({ name: 'New Item', quantity: 5 });

      expect(response.status).toBe(201);
      expect(mockDb.query).toHaveBeenCalledWith(
        'INSERT INTO items (name, quantity) VALUES ($1, $2)',
        ['New Item', 5]
      );
    });

    it('should return 400 if name is missing', async () => {
      const response = await request(app)
        .post('/')
        .send({ quantity: 5 });

      expect(response.status).toBe(400);
      expect(response.body).toEqual({ error: 'Name and price are required' });
    });

    it('should return 400 if quantity is missing', async () => {
      const response = await request(app)
        .post('/')
        .send({ name: 'New Item' });

      expect(response.status).toBe(400);
      expect(response.body).toEqual({ error: 'Name and price are required' });
    });

    it('should return 500 on database error', async () => {
      mockDb.query.mockRejectedValueOnce(new Error('DB Error') as never);

      const response = await request(app)
        .post('/')
        .send({ name: 'New Item', quantity: 5 });

      expect(response.status).toBe(500);
    });
  });
});
